const { Given, When, Then } = require('@cucumber/cucumber');
const assert = require('assert');
const { add, subtract } = require('../../calculator');

Given('我有一個計算機', function () {
  // 此步驟用於設定上下文，此處我們將計算函式附加到 this 物件上
  // 以便在後續的 When/Then 步驟中存取。
  this.calculator = { add, subtract };
});

When('我將 {int} 和 {int} 相加', function (num1, num2) {
  // 使用 calculator.js 中的 add 函式進行計算
  this.result = this.calculator.add(num1, num2);
});

When('我用 {int} 減去 {int}', function (num1, num2) {
  // 使用 calculator.js 中的 subtract 函式進行計算
  this.result = this.calculator.subtract(num1, num2);
});

Then('結果應該是 {int}', function (expected) {
  // 使用 Node.js 的 assert 模組來驗證結果是否符合預期
  assert.strictEqual(this.result, expected);
});

When('我嘗試將 {string} 和 {int} 相加', function (nonNumericInput, num2) {
  // 由於預期 add 函式會拋出錯誤，我們使用 try...catch 來捕獲它
  try {
    this.calculator.add(nonNumericInput, num2);
  } catch (e) {
    // 將捕獲到的錯誤儲存到 this.error 中，以便在 Then 步驟中進行驗證
    this.error = e;
  }
});

Then('應該要拋出錯誤', function () {
  // 斷言確實捕獲到了錯誤
  assert.ok(this.error, '預期應拋出錯誤，但沒有偵測到錯誤');
  // 並且斷言錯誤訊息符合預期
  assert.strictEqual(this.error.message, '所有輸入都必須是數字。');
});
