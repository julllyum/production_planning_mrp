import math
from datetime import timedelta, date, datetime
import psycopg2
import os

DB_CONFIG = {
    "host": os.getenv("DB_HOST", "localhost"),
    "port": int(os.getenv("DB_PORT", "5432")),
    "dbname": os.getenv("DB_NAME", "postgres"),
    "user": os.getenv("DB_USER", "postgres"),
    "password": os.getenv("DB_PASSWORD")
}

SCHEMA = "SupplyChain"

MAX_RESOURCE_HOURS = 23.0  # максимум часов на агрегат в сутки
MAX_ORDER_HOURS = 24.0     # максимум часов на заказ в сутки


def get_connection():
    return psycopg2.connect(**DB_CONFIG)


def set_schema(conn):
    with conn.cursor() as cur:
        cur.execute(f'SET search_path TO "{SCHEMA}";')
    conn.commit()


def clear_plan(conn):
    with conn.cursor() as cur:
        cur.execute(f"DELETE FROM {SCHEMA}.MRP_Plan")
    conn.commit()


def load_orders(conn):
    # загрузка заказов + приоритетов
    sql = f"""
    SELECT
        so.sales_order_id,
        so.customer_id,
        c.customer_priority,
        so.product_id,
        so.so_quantity,
        so.so_tolerance,
        so.due_date,
        so.unit_weight
    FROM SupplyChain.Sales_Order so
    JOIN SupplyChain.Customer c ON so.customer_id = c.customer_id
    ORDER BY c.customer_priority, so.due_date
    """

    with conn.cursor() as cur:
        cur.execute(sql)
        rows = cur.fetchall()

    # преобразование строк из БД в список словарей
    return [{
        "id": int(r[0]),
        "product": str(r[3]),
        "qty": float(r[4]),
        "tol": float(r[5]),
        "due": r[6],
        "unit": float(r[7])
    } for r in rows]


def load_ops(conn, product_id):
    # загрузка технологического маршрута для продукта
    sql = f"""
    SELECT
        so.resource_id,
        r.resource_desc,
        so.standard_op_no,
        so.standard_time,
        so.yield_percent
    FROM SupplyChain.Standard_Operation so
    JOIN SupplyChain.Resource r ON so.resource_id = r.resource_id
    WHERE so.product_id = %s
    ORDER BY so.standard_op_no DESC
    """

    with conn.cursor() as cur:
        cur.execute(sql, (product_id,))
        rows = cur.fetchall()

    return [{
        "res": int(r[0]),             # id ресурса
        "name": str(r[1]),            # название ресурса
        "op": int(r[2]),              # номер операции
        "perf": float(r[3]),          # производительность т/час
        "yield": float(r[4]) / 100.0  # выход годного в коэффициент
    } for r in rows]


def get_resource_used(conn, day, res_id):
    # сколько часов ресурса уже занято в конкретный день
    with conn.cursor() as cur:
        cur.execute(f"""
            SELECT COALESCE(SUM(required_hours), 0)
            FROM {SCHEMA}.MRP_Plan
            WHERE ready_date = %s
              AND resource_id = %s
        """, (day, res_id))

        value = cur.fetchone()[0]

    return float(value)


def get_order_used(conn, day, order_id):
    # сколько часов уже занято по конкретному заказу в день
    with conn.cursor() as cur:
        cur.execute(f"""
            SELECT COALESCE(SUM(required_hours), 0)
            FROM {SCHEMA}.MRP_Plan
            WHERE ready_date = %s AND sales_order_id = %s
        """, (day, order_id))

        value = cur.fetchone()[0]

    return float(value)


def insert_load(conn, order_id, product_id, res_id, op_no, qty, weight, hours, day, start_hour, end_hour):
    # запись одного куска операции в план

    # преобразуем часы в формат времени
    start_time = (datetime.min + timedelta(hours=start_hour)).time()
    end_time = (datetime.min + timedelta(hours=end_hour)).time()

    with conn.cursor() as cur:
        cur.execute(f"""
            INSERT INTO {SCHEMA}.MRP_Plan
            (
                sales_order_id,
                product_id,
                resource_id,
                operation_no,
                qty_units,
                weight_ton,
                required_hours,
                ready_date,
                start_time,
                end_time
            )
            VALUES
            (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)
        """, (
            order_id,
            product_id,
            res_id,
            op_no,
            round(qty, 3),
            round(weight, 2),
            round(hours, 2),
            day,
            start_time,
            end_time
        ))


def delivery_weight(req, unit, tol):
    # расчёт отгрузочного веса с учётом допуска

    down = math.floor(req / unit) * unit  # округление вниз до кратности

    if abs(req - down) <= tol:
        return down  # если попали в допуск – берём вниз

    return math.ceil(req / unit) * unit  # иначе округляем вверх


def round_up_to_unit(weight, unit):
    # округление веса до целого количества единиц продукции
    units = math.ceil(weight / unit)  # количество рулонов
    return units * unit


def plan_operation(conn, order, op, weight, end_date, end_hour):
    perf = op["perf"]  # производительность
    total_hours = weight / perf  # сколько часов нужно на весь объём

    remaining = total_hours  # оставшееся время операции
    day = end_date           # начинаем планирование с конечной даты

    current_end_hour = end_hour  # двигаемся назад по времени

    first_day = None  # самый ранний день операции
    first_hour = None

    horizon_start = date(2025, 4, 1)

    while remaining > 1e-9:  # пока есть нераспределённое время

        if day < horizon_start:
            raise Exception(f"не хватает мощности для заказа {order['id']}")

        # сколько уже занято на агрегате
        resource_used = get_resource_used(
            conn,
            day,
            op["res"]
        )

        resource_free = (MAX_RESOURCE_HOURS - resource_used)

        # сколько уже занято самим заказом
        order_used = get_order_used(
            conn,
            day,
            order["id"]
        )

        order_free = (MAX_ORDER_HOURS - order_used)

        # доступная мощность
        available = min(
            resource_free,
            order_free,
            remaining,
            current_end_hour
        )

        if available <= 1e-7:
            # если нет места – идём на предыдущий день
            day -= timedelta(days=1)

            current_end_hour = 24.0

            continue

        used = available  # фиксируем используемое время

        start_hour = current_end_hour - used
        end_hour_cur = current_end_hour

        # пересчёт веса и количества
        weight_part = (used / total_hours) * weight
        qty_part = weight_part / order["unit"]

        insert_load(
            conn,
            order["id"],
            order["product"],
            op["res"],
            op["op"],
            qty_part,
            weight_part,
            used,
            day,
            start_hour,
            end_hour_cur
        )

        remaining -= used

        # фиксируем старт операции
        first_day = day
        first_hour = start_hour

        # следующая часть операции продолжается раньше
        current_end_hour = start_hour

        # если в сутках больше нет места
        if current_end_hour <= 1e-7:
            day -= timedelta(days=1)

            current_end_hour = 24.0

    return first_day, first_hour


def run_order(conn, order):
    # обработка одного заказа целиком
    ops = load_ops(conn, order["product"])  # маршрут операций

    if not ops:
        print(f"нет маршрута для {order['product']}")
        return

    delivery = delivery_weight(
        order["qty"],
        order["unit"],
        order["tol"]
    )

    print(
        f"заказ {order['id']} "
        f"-> отгрузка {delivery:.0f} т"
    )

    current_weight = delivery

    current_date = order["due"]

    current_hour = 24.0  # стартуем с конца суток

    for i, op in enumerate(ops):

        # пересчёт веса назад через yield
        if i > 0:
            raw_weight = current_weight / op["yield"]

            current_weight = round_up_to_unit(
                raw_weight,
                order["unit"]
            )

        start_day, start_hour = plan_operation(
            conn,
            order,
            op,
            current_weight,
            current_date,
            current_hour
        )

        # предыдущая операция должна закончиться к старту следующей
        current_date = start_day
        current_hour = start_hour

    conn.commit()

    print(f"заказ {order['id']} рассчитан")


def main():

    conn = get_connection()

    try:

        set_schema(conn)
        clear_plan(conn)

        orders = load_orders(conn)

        for o in orders:
            run_order(conn, o)

        print("\nрасчёт завершён")

    finally:
        conn.close()

if __name__ == "__main__":
    main()
