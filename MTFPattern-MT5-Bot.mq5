//+------------------------------------------------------------------+
//|                                           MTFPattern-MT5-Bot.mq5 |
//|                                                  Denis Kislitsyn |
//|                                             https://kislitsyn.me |
//+------------------------------------------------------------------+

#property script_show_inputs


#include "Include\DKStdLib\Logger\CDKLogger.mqh"
#include "Include\DKStdLib\TradingManager\CDKTrade.mqh"
#include "CMTFPatternBot.mqh"

input  group                    "1. ENTRY (ENT)"
input  uint                      Inp_ENT_CNT                        = 1;               // ENT_CNT: Pos number open on signal
input  double                    Inp_ENT_LTV                        = 0.1;             // ENT_LTV: Pos Lot Value

input  group                    "2. SIGNAL (SIG)"
input  ENUM_TRADE_DIR            Inp_SIG_DIR                        = TRADE_DIR_BOTH;  // SIG_DIR: Signal Direction Allowed
input  ENUM_SIGNAL_MODE          Inp_SIG_MOD                        = ENUM_SIGNAL_LTF_ONLY; // SIG_MOD: Signal Mode
input  bool                      Inp_SIG_NBO                        = true;            // SIG_NBO: Signal on New Bar Only
input  ENUM_TIMEFRAMES           Inp_SIG_HTF                        = PERIOD_M30;      // SIG_HTF: Higher Timeframe
input  ENUM_TIMEFRAMES           Inp_SIG_LTF                        = PERIOD_M5;       // SIG_LTF: Lower Timeframe

input  group                    "3. FILTER (FIL)"
input  bool                      Inp_FIL_ENB                        = true;            // FIL_ENB: Filter Enabled
input  ENUM_MA_METHOD            Inp_FIL_MAM                        = MODE_EMA;        // FIL_MAM: MA Method
input  uint                      Inp_FIL_MAP                        = 9;               // FIL_MAP: MA Period

input  group                    "4. GUI"
input  bool                      Inp_GUI_ENB                        = true;            // GUI_ENB: Draw HTF bar Enabled
input  color                     Inp_GUI_CLR_LNG                    = clrGreen;        // GUI_CLR_LNG: Color for Long
input  color                     Inp_GUI_CLR_SHT                    = clrRed;          // GUI_CLR_SHT: Color for Short
input  bool                      Inp_GUI_BFL                        = true;            // GUI_BFL: Fill Bar




input  group                    "5. MISCELLANEOUS (MS)"
input  ulong                    Inp_MS_MGC                          = 20250109;                             // MS_MGC: Expert Adviser ID - Magic
sinput string                   Inp_MS_EGP                          = "MTFP"  ;                             // MS_EGP: Expert Adviser Global Prefix
sinput LogLevel                 Inp_MS_LOG_LL                       = LogLevel(INFO);                       // MS_LOG_LL: Log Level
sinput string                   Inp_MS_LOG_FI                       = "";                                   // MS_LOG_FI: Log Filter IN String (use `;` as sep)
sinput string                   Inp_MS_LOG_FO                       = "";                                   // MS_LOG_FO: Log Filter OUT String (use `;` as sep)
       bool                     Inp_MS_COM_EN                       = true;                                 // MS_COM_EN: Comment Enable (turn off for fast testing)
       uint                     Inp_MS_COM_IS                       = 60;                                   // MS_COM_IS: Comment Interval, Sec
       bool                     Inp_MS_COM_CW                       = false;                                // MS_COM_EW: Comment Custom Window
       
       long                     Inp_PublishDate                                         = 20250117;                           // Date of publish
       int                      Inp_DurationBeforeExpireSec                             = 5*24*60*60;                         // Duration before expire, sec       

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

  if (TimeCurrent() > StringToTime((string)Inp_PublishDate) + Inp_DurationBeforeExpireSec) {
    logger.Critical("Test version is expired", true);
    return(INIT_FAILED);
  }  
  
  trade.Init(Symbol(), Inp_MS_MGC, 0, GetPointer(logger));

  CMTFPatternBotInputs inputs;
  inputs.ENT_CNT                   = Inp_ENT_CNT;                                        // ENT_CNT: Pos number open on signal
  inputs.ENT_LTV                   = Inp_ENT_LTV;                                        // ENT_LTV: Pos Lot Value
  inputs.SIG_DIR                   = Inp_SIG_DIR;                                        // SIG_DIR: Signal Direction Allowed
  inputs.SIG_MOD                   = Inp_SIG_MOD;                                        // SIG_MOD: Signal Mode
  inputs.SIG_NBO                   = Inp_SIG_NBO;                                        // SIG_NBO: Signal on New Bar Only
  inputs.SIG_HTF                   = Inp_SIG_HTF;                                        // SIG_HTF: Higher Timeframe
  inputs.SIG_LTF                   = Inp_SIG_LTF;                                        // SIG_LTF: Lower Timeframe
  inputs.FIL_ENB                   = Inp_FIL_ENB;                                        // FIL_ENB: Filter Enabled
  inputs.FIL_MAM                   = Inp_FIL_MAM;                                        // FIL_MAM: MA Method
  inputs.FIL_MAP                   = Inp_FIL_MAP;                                        // FIL_MAP: MA Period
  inputs.GUI_ENB                   = Inp_GUI_ENB;                                        // GUI_ENB: Draw HTF bar Enabled
  inputs.GUI_CLR_LNG               = Inp_GUI_CLR_LNG;                                    // GUI_CLR_LNG: Color for Long
  inputs.GUI_CLR_SHT               = Inp_GUI_CLR_SHT;                                    // GUI_CLR_SHT: Color for Short
  inputs.GUI_BFL                   = Inp_GUI_BFL;                                        // GUI_BFL: Fill Bar
  
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