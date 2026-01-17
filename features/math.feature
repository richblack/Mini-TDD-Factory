Feature: 基礎計算機運算

  Scenario: 兩個數字相加
    Given 我有一個計算機
    When 我將 5 和 3 相加
    Then 結果應該是 8

  Scenario: 兩個數字相減
    Given 我有一個計算機
    When 我用 10 減去 3
    Then 結果應該是 7

  Scenario: 嘗試將非數字相加
    Given 我有一個計算機
    When 我嘗試將 "a" 和 5 相加
    Then 應該要拋出錯誤
