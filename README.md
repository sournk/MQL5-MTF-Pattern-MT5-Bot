# MQL5-MTF-Pattern-MT5-Bot
The bot for MetaTrader 5 with custom multi time frame pattern strategy.

* Created by Denis Kislitsyn | denis@kislitsyn.me | [kislitsyn.me](https://kislitsyn.me/personal/algo)
* MQL5 Freelance: https://www.mql5.com/en/job/230439
* Version: 1.01


## What's new?
```
1.01: [+] 'LTF Only' mode
1.00: First version
```

!!! warning WARNING
    1. The trading strategy is determined by the client and the author is not responsible for it.
    2. The bot does not guarantee profit.
    3. The bot does not guarantee 100% deposit protection.
    4. Use the bot at your own risk.

![Layout](img/UM001.%20Layout.gif)

## Strategy Check List

- [x] Directional Trading: The bot will only place trades on the LTF in the direction of the current HTF candle.
    - [x] If the HTF candle is bullish, trades will only be executed in the bullish direction on the LTF.
    - [x] If the HTF candle is bearish, trades will only be executed in the bearish direction on the LTF.

- [x] Trade Execution and Continuity:
    - [x] Trades will be initiated at the open of the current HTF candle. 
        > When the `SIG_NBO` is `true` the bot enters only in the beginning of HTF candle. Turn it to `false` to allow the bot to enter inside HTF on signal.==

    - [x] Trades will remain open as long as the trend on the LTF aligns with the HTF candle direction.
    - [x] If the next LTF candle changes direction (e.g., from bullish to bearish), the bot will close all open positions.
    - [x] If the next HTF candle continues the trend of the previous HTF candle, trades will continue without closure.

- [x] Drawdown Management:
    - [x] Drawdowns will only be permitted during the entry of a trade.
        > Drawdown is only possible until first LTF candle is still open.
    - [x] No trade should go into a negative state beyond the initial entry drawdown.
    - [x] If a trade reaches a break-even point (0.00 profit/loss), it will automatically close.

- [x] Trade Closure Rules:
    - [x] Trades must close at the close of the HTF candle unless the trend continues.
    - [x] All trades will close if the LTF or HTF trend reverses.

- [x] Candle Analysis
    - [x] Analyze HTF candles to determine the current trend (bullish or bearish).
    - [x] Continuously monitor LTF candles to align trades with the HTF trend.
    - [x] Detect changes in the direction of LTF candles for trade closure.

- [x] Trade Management
    - [x] Trade Opening:
        - [x] Open trades on the LTF in the direction of the current HTF candle at its open.
        - [x] Limit trades to the current candle’s time frame on both HTF and LTF.
    - [x] Trade Monitoring:
        - [x] Ensure trades remain within acceptable drawdown limits.
        - [x] Automatically close trades at break-even (0.00 profit/loss).
    - [x] Trade Closure:
        - [x] Close trades at the end of the HTF candle unless the next HTF candle continues the trend.
        - [x] Close trades immediately if the LTF candle reverses direction.

- [x] Risk Management
    - [x] strict drawdown policies to avoid prolonged negative trades.
    - [x] no trade remains open in a negative state beyond acceptable limits.
    - [x] Prevent trades that contradict the HTF candle trend.

- [x] 3.4. Automation and Execution
    - [x] Fully automate the detection of HTF and LTF candles and their respective trends.
    - [x] Monitor candle changes in real-time to ensure timely execution and closure of trades.

- [x] 4. Non-Functional Requirements
    - [x] Performance:
        - [x] The bot should execute trades with minimal latency.
        - [x] Candle analysis and trade monitoring should occur in real-time.
    - [x] Reliability:
        - [x] Ensure continuous uptime during trading sessions.
        - [x] Maintain accurate detection of candle trends to avoid erroneous trades.
    - [x] Scalability:
        - [x] Support multiple trading pairs and time frames as required.
        > Use different magic in `MS_MGC` to separate instances of the bot.

- [x] 5. Additional Considerations
    - [x] The bot should log all trades and events for audit and analysis purposes.
        > Use `MS_LOG_LL` to set log level.
    - [x] Customizable parameter settings for:
        - [x] HTF and LTF time frame selection.
        - [x] No of trade
        - [x] Lot size
        - [x] 9 ema paramerter where trades are place with respect to it

- [x] Summary This trading bot will follow a structured and disciplined approach to trade execution based on HTF and LTF candle trends. By ensuring trades align strictly with these trends and implementing robust riskmangement management

- [x] ==New mode `LTF only`==: https://www.mql5.com/en/job/230439/discussion?id=1117936&comment=55646809. 
    - [x] 1. The bot opens pos if LTF candle close with same dir as MA.
    - [x] 2. MA direction is an angle of MA build by last two candles: >0.0 up; <0.0 down.
    - [x] 3. After that the bot keeps pos in the market until LTF candle reverses.
    ![LTF mode layout](img/UM001.%20LTF%20Mode%20Layout.png)

## Installation
1. Make sure that your MetaTrader 5 terminal is updated to the latest version. To test Expert Advisors, it is recommended to update the terminal to the latest beta version. To do this, run the update from the main menu `Help->Check For Updates->Latest Beta Version`. The Expert Advisor may not run on previous versions because it is compiled for the latest version of the terminal. In this case you will see messages on the `Journal` tab about it.
2. Copy the bot executable file `*.ex5` to the terminal data directory `MQL5\Experts`.
3. Open the pair chart.
4. Move the Expert Advisor from the Navigator window to the chart.
5. Check `Allow Auto Trading` in the bot settings.
6. Enable the auto trading mode in the terminal by clicking the `Algo Trading` button on the main toolbar.
7. Load the set of settings by clicking the `Load` button and selecting the set-file.

8. ==Run the bot on the chart TF, which is the same with `SIG_LTF` input. It's needed to draw HTF candle rectangle and EMA line.==

## Inputs

##### 1. ENTRY (ENT)
- [x] `ENT_CNT`: Pos number open on signal
- [x] `ENT_LTV`: Pos Lot Value

##### 2. SIGNAL (SIG)
- [x] `SIG_DIR`: Signal Direction Allowed
- [x] `SIG_MOD`: Signal Mode
- [x] `SIG_NBO`: Signal on New Bar Only
- [x] `SIG_HTF`: Higher Timeframe
- [x] `SIG_LTF`: Lower Timeframe

##### 3. FILTER (FIL)
- [x] `FIL_ENB`: Filter Enabled
- [x] `FIL_MAM`: MA Method
- [x] `FIL_MAP`: MA Period

##### 4. GUI
- [x] `GUI_ENB`: Draw HTF bar Enabled
- [x] `GUI_CLR_LNG`: Color for Long
- [x] `GUI_CLR_SHT`: Color for Short
- [x] `GUI_BFL`: Fill Bar

##### 5. MISCELLANEOUS (MS)
- [x] `MS_MGC`: Expert Adviser ID - Magic
- [x] `MS_EGP`: Expert Adviser Global Prefix
- [x] `MS_LOG_LL`: Log Level
- [x] `MS_LOG_FI`: Log Filter IN String (use `;` as sep)
- [x] `MS_LOG_FO`: Log Filter OUT String (use `;` as sep)