INSERT INTO categories (id, name, description, created_at, updated_at) VALUES (1, 'Pizzas', 'Freshly baked pizzas', datetime('now'), datetime('now')) ON CONFLICT(id) DO NOTHING;

INSERT INTO products (name, description, price, stock, status, image, category_id, created_at, updated_at) VALUES 
('Pepperoni Pizza', 'A delicious classic pepperoni pizza.', 12.99, 50, 'available', 'pepperoni_pizza.png', 1, datetime('now'), datetime('now')),
('Margherita Pizza', 'Fresh basil and mozzarella on a classic crust.', 11.99, 45, 'available', 'margherita_pizza.png', 1, datetime('now'), datetime('now')),
('BBQ Chicken Pizza', 'BBQ chicken, red onions, and cilantro.', 14.99, 40, 'available', 'bbq_chicken_pizza.png', 1, datetime('now'), datetime('now')),
('Hawaiian Pizza', 'Ham and pineapple chunks on a cheesy base.', 13.99, 35, 'available', 'hawaiian_pizza.png', 1, datetime('now'), datetime('now')),
('Veggie Pizza', 'Bell peppers, olives, mushrooms, and onions.', 12.99, 40, 'available', 'veggie_pizza.png', 1, datetime('now'), datetime('now')),
('Meat Lovers Pizza', 'Sausage, bacon, ham, and pepperoni for meat enthusiasts.', 15.99, 30, 'available', 'meat_lovers_pizza.png', 1, datetime('now'), datetime('now'));
