# MQL5-MTF-Pattern-MT5-Bot
The bot for MetaTrader 5 with custom multi time frame pattern strategy.

* Created by Denis Kislitsyn | denis@kislitsyn.me | [kislitsyn.me](https://kislitsyn.me/personal/algo)
* MQL5 Freelance: https://www.mql5.com/en/job/230439
* Version: 1.00


## What's new?
```
1.00: First version
```

!!! warning Предупреждение
    1. Стратегию разрабатывал на фьюче CNY на Финаме - CRH5. 
    2. График торгов очень рваный даже на высоких ТФ. ==Сделки будут сильно скользить особенно на больших лотах из низкой ликвидности.==
    3. Расчет лота стратегии описан как простая формула Депозит/Цена*Сайз_%. По ней без плеч не хватит депозита для Сайза > 100%. ==Это очень странная формула.==

## Strategy

#### Signal

**Open trade on LTH bar closing only when HTF bar is same dir**

- [ ] Directional Trading: The bot will only place trades on the LTF in the direction of the current HTF candle.
    - [ ] If the HTF candle is bullish, trades will only be executed in the bullish direction on the LTF.
    - [ ] If the HTF candle is bearish, trades will only be executed in the bearish direction on the LTF.

- [ ] Trade Execution and Continuity:
    - [ ] Trades will be initiated at the open of the current HTF candle.
    - [ ] Trades will remain open as long as the trend on the LTF aligns with the HTF candle direction.
    - [ ] If the next LTF candle changes direction (e.g., from bullish to bearish), the bot will close all open positions.
    - [ ] If the next HTF candle continues the trend of the previous HTF candle, trades will continue without closure.

- [ ] Drawdown Management:
    - [ ] Drawdowns will only be permitted during the entry of a trade.
    - [ ] No trade should go into a negative state beyond the initial entry drawdown.
    - [ ] If a trade reaches a break-even point (0.00 profit/loss), it will automatically close.

- [ ] Trade Closure Rules:
    - [ ] Trades must close at the close of the HTF candle unless the trend continues.
    - [ ] All trades will close if the LTF or HTF trend reverses.

- [ ] Candle Analysis
    - [ ] Analyze HTF candles to determine the current trend (bullish or bearish).
    - [ ] Continuously monitor LTF candles to align trades with the HTF trend.
    - [ ] Detect changes in the direction of LTF candles for trade closure.

- [ ] Trade Management
    - [ ] Trade Opening:
        - [ ] Open trades on the LTF in the direction of the current HTF candle at its open.
        - [ ] Limit trades to the current candle’s time frame on both HTF and LTF.
    - [ ] Trade Monitoring:
        - [ ] Ensure trades remain within acceptable drawdown limits.
        - [ ] Automatically close trades at break-even (0.00 profit/loss).
    - [ ] Trade Closure:
        - [ ] Close trades at the end of the HTF candle unless the next HTF candle continues the trend.
        - [ ] Close trades immediately if the LTF candle reverses direction.

- [ ] Risk Management
    - [ ] strict drawdown policies to avoid prolonged negative trades.
    - [ ] no trade remains open in a negative state beyond acceptable limits.
    - [ ] Prevent trades that contradict the HTF candle trend.

- [ ] 3.4. Automation and Execution
    - [ ] Fully automate the detection of HTF and LTF candles and their respective trends.
    - [ ] Monitor candle changes in real-time to ensure timely execution and closure of trades.

- [ ] 4. Non-Functional Requirements
    - [ ] Performance:
        - [ ] The bot should execute trades with minimal latency.
        - [ ] Candle analysis and trade monitoring should occur in real-time.
    - [ ] Reliability:
        - [ ] Ensure continuous uptime during trading sessions.
        - [ ] Maintain accurate detection of candle trends to avoid erroneous trades.
    - [ ] Scalability:
        - [ ] Support multiple trading pairs and time frames as required.

- [ ] 5. Additional Considerations
    - [ ] The bot should log all trades and events for audit and analysis purposes.
    - [ ] Customizable parameter settings for:
        - [ ] HTF and LTF time frame selection.
        - [ ] No of trade
        - [ ] Lot size
        - [ ] 9 ema paramerter where trades are place with respect to it

- [ ] Summary This trading bot will follow a structured and disciplined approach to trade execution based on HTF and LTF candle trends. By ensuring trades align strictly with these trends and implementing robust riskmangement management

## Installation
1. Make sure that your MetaTrader 5 terminal is updated to the latest version. To test Expert Advisors, it is recommended to update the terminal to the latest beta version. To do this, run the update from the main menu `Help->Check For Updates->Latest Beta Version`. The Expert Advisor may not run on previous versions because it is compiled for the latest version of the terminal. In this case you will see messages on the `Journal` tab about it.
2. Copy the bot executable file `*.ex5` to the terminal data directory `MQL5\Experts`.
3. Open the pair chart.
4. Move the Expert Advisor from the Navigator window to the chart.
5. Check `Allow Auto Trading` in the bot settings.
6. Enable the auto trading mode in the terminal by clicking the `Algo Trading` button on the main toolbar.
7. Load the set of settings by clicking the `Load` button and selecting the set-file.

## Inputs

