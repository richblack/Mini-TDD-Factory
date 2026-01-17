// calculator.js

/**
 * 驗證所有輸入是否皆為數字。
 * 若有任何輸入非數字，則會拋出錯誤。
 * @param  {...any} numbers - 一或多個要驗證的數字。
 */
function validateNumbers(...numbers) {
    for (const num of numbers) {
        if (typeof num !== 'number') {
            throw new Error('所有輸入都必須是數字。');
        }
    }
}

/**
 * 將兩個數字相加。
 * @param {number} a - 第一個數字。
 * @param {number} b - 第二個數字。
 * @returns {number} 兩個數字相加的結果。
 */
function add(a, b) {
    validateNumbers(a, b);
    return a + b;
}

/**
 * 將第二個數字從第一個數字中減去。
 * @param {number} a - 第一個數字。
 * @param {number} b - 第二個數字。
 * @returns {number} 兩個數字相減的結果。
 */
function subtract(a, b) {
    validateNumbers(a, b);
    return a - b;
}

module.exports = { add, subtract };
