INSERT INTO SupplyChain.Customer VALUES
(1, 2, 'ПМХ', 100),
(2, 1, 'НЛМК Авто', 101),
(3, 2, 'Акрон', 102),
(4, 1, 'Инпром', 103),
(5, 3, 'Синара', 104),
(6, 4, 'АвтоВАЗ', 105),
(7, 3, 'Белаз', 106),
(8, 1, 'СпбВерфь', 107);

INSERT INTO SupplyChain.Resource VALUES
(1, 'Прокатный стан г/п', 1, NULL, NULL, 1),
(2, 'Прокатный стан х/п', 1, NULL, NULL, 1),
(3, 'Агрегат резки', 1, NULL, NULL, 1),
(4, 'Линия упаковки', 1, NULL, NULL, 1),
(5, 'Агрегат травления', 1, NULL, NULL, 1),
(6, 'Линия АНО', 1, NULL, NULL, 1),
(7, 'Отжиг в КП', 1, NULL, NULL, 1),
(8, 'Линия дрессировки', 1, NULL, NULL, 1);

INSERT INTO SupplyChain.Product VALUES
('SLAB001', 'Сляб', 'P', 20.00, 25.00, 'SLAB', 'SLAB'),
('HRC001', 'Рулон г/к', 'P', 10.00, 15.00, 'HRC', 'COIL'),
('HRC_PICK', 'Рулон г/к травленный', 'P', 8.00, 12.00, 'HRC_PICK', 'COIL'),
('CRC_ANO', 'Рулон х/к с АНО', 'F', 7.00, 12.00, 'CRC_ANO', 'COIL'),
('CRC_SKIN', 'Рулон х/к дресс', 'F', 8.00, 15.00, 'CRC_SKIN', 'COIL'),
('HRC_SO', 'Рулон г/к', 'F', 10.00, 15.00, 'HRC', 'COIL'),
('CRC_COIL', 'Рулон х/к', 'F', 7.00, 15.00, 'CRC', 'COIL');


-- HRC_SO Рулон г/к
INSERT INTO SupplyChain.Standard_Operation VALUES
('HRC_SO', 1, 1, 10, 'P', 160, 98.4),   -- Прокатный стан г/п
('HRC_SO', 3, 1, 20, 'P', 170, 98.4),   -- Агрегат резки
('HRC_SO', 4, 1, 30, 'P', 190, 100);    -- Линия упаковки

-- HRC_PICK Рулон г/к травленный
INSERT INTO SupplyChain.Standard_Operation VALUES
('HRC_PICK', 1, 1, 10, 'P', 160, 98.4),   -- Прокатный стан г/п
('HRC_PICK', 5, 1, 20, 'P', 185, 100),    -- Агрегат травления
('HRC_PICK', 3, 1, 30, 'P', 170, 98.4),   -- Агрегат резки
('HRC_PICK', 4, 1, 40, 'P', 190, 100);    -- Линия упаковки

-- CRC_COIL Рулон х/к
INSERT INTO SupplyChain.Standard_Operation VALUES
('CRC_COIL', 1, 1, 10, 'P', 160, 98.4),   -- Прокатный стан г/п
('CRC_COIL', 5, 1, 20, 'P', 185, 100),    -- Агрегат травления
('CRC_COIL', 2, 1, 30, 'P', 210, 99.2),   -- Прокатный стан х/п 
('CRC_COIL', 3, 1, 40, 'P', 170, 98.4),   -- Агрегат резки
('CRC_COIL', 4, 1, 50, 'P', 190, 100);    -- Линия упаковки

-- CRC_ANO Рулон х/к с АНО
INSERT INTO SupplyChain.Standard_Operation VALUES
('CRC_ANO', 1, 1, 10, 'P', 160, 98.4),   -- Прокатный стан г/п
('CRC_ANO', 5, 1, 20, 'P', 185, 100),    -- Агрегат травления
('CRC_ANO', 2, 1, 30, 'P', 210, 99.2),   -- Прокатный стан х/п 
('CRC_ANO', 6, 1, 40, 'P', 170, 100),    -- Линия АНО
('CRC_ANO', 3, 1, 50, 'P', 170, 98.4),   -- Агрегат резки
('CRC_ANO', 4, 1, 60, 'P', 190, 100);    -- Линия упаковки

-- CRC_SKIN Рулон х/к дресс
INSERT INTO SupplyChain.Standard_Operation VALUES
('CRC_SKIN', 1, 1, 10, 'P', 160, 98.4),   -- Прокатный стан г/п
('CRC_SKIN', 5, 1, 20, 'P', 185, 100),    -- Агрегат травления
('CRC_SKIN', 2, 1, 30, 'P', 210, 99.2),   -- Прокатный стан х/п 
('CRC_SKIN', 7, 1, 40, 'P', 80, 100),     -- Отжиг в КП
('CRC_SKIN', 8, 1, 50, 'P', 190, 100),    -- Линия дрессировки
('CRC_SKIN', 3, 1, 60, 'P', 170, 98.4),   -- Агрегат резки
('CRC_SKIN', 4, 1, 70, 'P', 190, 100);    -- Линия упаковки

-- Product_Link
INSERT INTO SupplyChain.Product_Link VALUES
(1, 'CRC_ANO', 'HRC_PICK', 'B', 1),
(2, 'CRC_SKIN', 'HRC_PICK', 'B', 1),
(3, 'CRC_COIL', 'HRC_PICK', 'B', 1),
(4, 'HRC_PICK', 'HRC001', 'B', 1),
(5, 'HRC001', 'SLAB001', 'B', 1);

-- Sales_Order 
INSERT INTO SupplyChain.Sales_Order (
    sales_order_id, customer_id, product_id, so_quantity, so_tolerance,
    shipped_quantity, so_status, orig_due_date, due_date, release_date,
    ship_to_location, original_from_date, unit_weight
) VALUES
(1001, 1, 'CRC_ANO', 6500, 12, NULL, 1, '2025-04-20', '2025-04-20', NULL, 'Склад ГП', '2025-03-01', 11),
(1002, 2, 'CRC_SKIN', 1000, 10, NULL, 1, '2025-04-17', '2025-04-17', NULL, 'Склад ГП', '2025-03-01', 8),
(1003, 3, 'HRC_SO', 1000, 20, NULL, 1, '2025-04-28', '2025-04-28', NULL, 'Склад ГП', '2025-03-01', 15),
(1004, 4, 'CRC_COIL', 4200, 10, NULL, 1, '2025-04-30', '2025-04-30', NULL, 'Склад ГП', '2025-03-01', 8),
(1005, 5, 'CRC_ANO', 3000, 10, NULL, 1, '2025-04-14', '2025-04-14', NULL, 'Склад ГП', '2025-03-01', 10),
(1006, 6, 'CRC_COIL', 2000, 15, NULL, 1, '2025-04-10', '2025-04-10', NULL, 'Склад ГП', '2025-03-01', 7),
(1007, 7, 'CRC_SKIN', 1910, 10, NULL, 1, '2025-04-05', '2025-04-05', NULL, 'Склад ГП', '2025-03-01', 9),
(1008, 8, 'HRC_PICK', 5000, 15, NULL, 1, '2025-04-12', '2025-04-12', NULL, 'Склад ГП', '2025-03-01', 14);


INSERT INTO SupplyChain.Calendar_Capacity (work_date, resource_id, available_hours)
SELECT d, r.resource_id, 23.00
FROM generate_series('2025-04-01'::date, '2025-04-30'::date, '1 day') d
CROSS JOIN SupplyChain.Resource r;


-- Установка ограничений по календарю
-- Прокатный стан г/п (1)
UPDATE SupplyChain.Calendar_Capacity SET available_hours = 10 WHERE work_date = '2025-04-18';
UPDATE SupplyChain.Calendar_Capacity SET available_hours = 10 WHERE work_date = '2025-04-21';

-- Прокатный стан х/п (2)
UPDATE SupplyChain.Calendar_Capacity SET available_hours = 8  WHERE work_date IN ('2025-04-03', '2025-04-04', '2025-04-05');
UPDATE SupplyChain.Calendar_Capacity SET available_hours = 16 WHERE work_date = '2025-04-06';

-- Агрегат резки (3)
UPDATE SupplyChain.Calendar_Capacity SET available_hours = 5 WHERE work_date IN ('2025-04-15', '2025-04-18');
