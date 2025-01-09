//+------------------------------------------------------------------+
//|                                           MTFPattern-MT5-Bot.mq5 |
//|                                                  Denis Kislitsyn |
//|                                             https://kislitsyn.me |
//+------------------------------------------------------------------+

#property script_show_inputs


#include "Include\DKStdLib\Logger\CDKLogger.mqh"
#include "Include\DKStdLib\TradingManager\CDKTrade.mqh"
#include "CMTFPatternBot.mqh"



input  group                    "5. MISCELLANEOUS (MS)"
input  ulong                    Inp_MS_MGC                          = 20250107;                             // MS_MGC: Expert Adviser ID - Magic
sinput string                   Inp_MS_EGP                          = "DSMTFPattern";                             // MS_EGP: Expert Adviser Global Prefix
sinput LogLevel                 Inp_MS_LOG_LL                       = LogLevel(INFO);                       // MS_LOG_LL: Log Level
sinput string                   Inp_MS_LOG_FI                       = "";                                   // MS_LOG_FI: Log Filter IN String (use `;` as sep)
sinput string                   Inp_MS_LOG_FO                       = "";                                   // MS_LOG_FO: Log Filter OUT String (use `;` as sep)
       bool                     Inp_MS_COM_EN                       = true;                                 // MS_COM_EN: Comment Enable (turn off for fast testing)
       uint                     Inp_MS_COM_IS                       = 60;                                   // MS_COM_IS: Comment Interval, Sec
       bool                     Inp_MS_COM_CW                       = false;                                // MS_COM_EW: Comment Custom Window

CMTFPatternBot                  bot;
CDKTrade                        trade;
CDKLogger                       logger;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit(){  
  logger.Init(Inp_MS_EGP, Inp_MS_LOG_LL);
  logger.FilterInFromStringWithSep(Inp_MS_LOG_FI, ";");
  logger.FilterOutFromStringWithSep(Inp_MS_LOG_FO, ";");
  
  trade.Init(Symbol(), Inp_MS_MGC, 0, GetPointer(logger));


  
  bot.CommentEnable                = Inp_MS_COM_EN;
  bot.CommentIntervalSec           = Inp_MS_COM_IS;
  
  bot.Init(Symbol(), Inp_SIG_LTF, Inp_MS_MGC, trade, Inp_MS_COM_CW, inputs, GetPointer(logger));
  bot.SetFont("Courier New");
  bot.SetHighlightSelection(true);

  if (!bot.Check()) 
    return(INIT_PARAMETERS_INCORRECT);

  EventSetTimer(Inp_MS_COM_IS);
  
  return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)  {
  bot.OnDeinit(reason);
  EventKillTimer();
}
  
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()  {
  bot.OnTick();
}

//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()  {
  bot.OnTimer();
}

//+------------------------------------------------------------------+
//| Trade function                                                   |
//+------------------------------------------------------------------+
void OnTrade()  {
  bot.OnTrade();
}

//+------------------------------------------------------------------+
//| TradeTransaction function                                        |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction& trans,
                        const MqlTradeRequest& request,
                        const MqlTradeResult& result) {
  bot.OnTradeTransaction(trans, request, result);
}

double OnTester() {
  return bot.OnTester();
}

void OnChartEvent(const int id,
                  const long& lparam,
                  const double& dparam,
                  const string& sparam) {
  bot.OnChartEvent(id, lparam, dparam, sparam);                                    
}