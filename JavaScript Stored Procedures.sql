/* ===============================================================
   Reviewer: Ollear Mena
   Company: ELITEDATA S.L.  
   Script:      JavaScript Stored Procedures.sql  
   Lab Title:   JavaScript Stored Procedures in Oracle Database 26ai  
   Description: Demonstrates how to create, execute, and manage 
                JavaScript-based stored procedures within Oracle Database 26ai 
                using the integrated JavaScript runtime engine.  
                Includes examples for function creation, invocation, 
                and parameter handling.  
   References:  https://docs.oracle.com/en/database/oracle/oracle-database/26/javascript/
   Version:     1.0  
   Date:        SYSDATE  
   =============================================================== */


create or replace mle module bookstore_module 
language javascript as
/**
 * Calculates the final price after discount
 * @param {number} price - Original book price
 * @param {number} discountPercent - Discount percentage (e.g., 20 for 20% off)
 * @returns {number} The final price after discount
 */
function calculateDiscountedPrice(price, discountPercent) {
    const discount = price * (discountPercent / 100);
    return price - discount;
}
export { calculateDiscountedPrice }
/

create or replace function get_final_price(
    price number,
    discount number
) return number as
mle module bookstore_module
signature 'calculateDiscountedPrice';
/

select get_final_price(20, 20) as final_price;

create or replace mle env bookstore_env
imports (
    'bookstore_module' module bookstore_module
);

create or replace mle module shipping_module
language javascript as
import * as bookstore from "bookstore_module";

/**
 * calculates total cost including shipping
 * @param {number} price - book price
 * @param {number} discount - discount percentage
 * @param {number} weight - book weight in pounds
 * @returns {number} total cost including shipping
 */
export function calculateTotalWithShipping(price, discount, weight) {
    const baseShippingRate = 2;  // $2 base rate
    const pricePerPound = 1.5;   // $1.50 per pound

    // First calculate the discounted price using our previous function
    const finalPrice = bookstore.calculateDiscountedPrice(price, discount);

    // Calculate shipping based on weight
    const shippingCost = baseShippingRate + (weight * pricePerPound);

    // Log the breakdown for transparency
    console.log(`Book price after discount: $${finalPrice}`);
    console.log(`Shipping cost: $${shippingCost}`);

    return finalPrice + shippingCost;
}
/

create or replace function get_total_with_shipping(
    price number,
    discount number,
    weight number
) return number as
mle module shipping_module
env bookstore_env
signature 'calculateTotalWithShipping';
/

select get_total_with_shipping(20, 20, 2) as total_cost;

declare
    l_ctx dbms_mle.context_handle_t;
begin
    dbms_output.enable(null);
    l_ctx := dbms_mle.create_context();

    dbms_mle.eval(
        context_handle => l_ctx,
        language_id => 'JAVASCRIPT',
        source => q'~
            // Create an array of books with prices and discounts
            const books = [
                {name: "JavaScript Guide", price: 29.99, discount: 15},
                {name: "Database Basics", price: 24.99, discount: 10}
            ];

            // Calculate final price for each book
            books.forEach(book => {
                const finalPrice = book.price * (1 - book.discount/100);
                console.log(`${book.name}: $${finalPrice.toFixed(2)} (${book.discount}% off)`);
            });
        ~'
    );

    dbms_mle.drop_context(l_ctx);
end;
/

declare
    l_ctx dbms_mle.context_handle_t;
begin
    dbms_output.enable(null);
    l_ctx := dbms_mle.create_context();

    dbms_mle.eval(
        context_handle => l_ctx,
        language_id => 'JAVASCRIPT',
        source => q'~
            function calculateOrder(bookPrice, quantity, discountPercent) {
                // Start with basic information
                console.log(`Debug: Starting calculation for order...`);
                console.log(`Debug: Input values:`);
                console.log(`  - Book price: $${bookPrice}`);
                console.log(`  - Quantity: ${quantity}`);
                console.log(`  - Discount: ${discountPercent}%`);

                // Calculate subtotal
                const subtotal = bookPrice * quantity;
                console.log(`Debug: Subtotal (${bookPrice} × ${quantity}): $${subtotal}`);

                // Calculate discount amount
                const discount = subtotal * (discountPercent / 100);
                console.log(`Debug: Discount calculation:`);
                console.log(`  - ${discountPercent}% of $${subtotal}`);
                console.log(`  - Discount amount: $${discount}`);

                // Calculate final price
                const final = subtotal - discount;
                console.log(`Debug: Final price: $${final}`);
                return final;
            }

            // Test the function with a real order
            console.log('Testing order calculation...');
            calculateOrder(19.99, 3, 15);
        ~'
    );

    dbms_mle.drop_context(l_ctx);
end;

/
