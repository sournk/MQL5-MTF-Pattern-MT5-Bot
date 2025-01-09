//+------------------------------------------------------------------+
//|                                               CMTFPatternBot.mqh |
//|                                                  Denis Kislitsyn |
//|                                             https://kislitsyn.me |
//+------------------------------------------------------------------+
#include <Generic\HashMap.mqh>
//#include <Arrays\ArrayString.mqh>
//#include <Arrays\ArrayObj.mqh>
#include <Arrays\ArrayDouble.mqh>
//#include <Arrays\ArrayLong.mqh>
//#include <Trade\TerminalInfo.mqh>
#include <Trade\DealInfo.mqh>
//#include <Charts\Chart.mqh>
#include <Math\Stat\Math.mqh>
#include <Trade\OrderInfo.mqh>

//#include <ChartObjects\ChartObjectsShapes.mqh>
#include <ChartObjects\ChartObjectsLines.mqh>
#include <ChartObjects\ChartObjectsArrows.mqh> 

#include "Include\DKStdLib\Analysis\DKChartAnalysis.mqh"
//#include "Include\DKStdLib\Common\DKStdLib.mqh"

//#include "Include\DKStdLib\Common\CDKString.mqh"
//#include "Include\DKStdLib\Logger\CDKLogger.mqh"
//#include "Include\DKStdLib\TradingManager\CDKPositionInfo.mqh"
//#include "Include\DKStdLib\TradingManager\CDKTrade.mqh"
//#include "Include\DKStdLib\TradingManager\CDKTSLStep.mqh"
//#include "Include\DKStdLib\TradingManager\CDKTSLStepSpread.mqh"
#include "Include\DKStdLib\TradingManager\CDKTSLFibo.mqh"
//#include "Include\DKStdLib\Drawing\DKChartDraw.mqh"
//#include "Include\DKStdLib\History\DKHistory.mqh"

#include "Include\DKStdLib\Common\CDKString.mqh"
#include "Include\DKStdLib\Common\DKDatetime.mqh"
#include "Include\DKStdLib\Arrays\CDKArrayString.mqh"
#include "Include\DKStdLib\Bot\CDKBaseBot.mqh"

#include "CMTFPatternInputs.mqh"


class CMTFPatternBot : public CDKBaseBot<CMTFPatternBotInputs> {
public: // SETTINGS

protected:
  MqlDateTime                SignalTime;
  datetime                   SignalMinDate;
  
  MqlDateTime                CloseTime;
  datetime                   CloseMinDate;
  
  CArrayString               WeekDayAllowedLong;
  CArrayString               WeekDayAllowedShort;
  
  datetime                   NextM1Time;
  
public:
  // Constructor & init
  //void                       CMTFPatternBot::CMTFPatternBot(void);
  void                       CMTFPatternBot::~CMTFPatternBot(void);
  void                       CMTFPatternBot::InitChild();
  bool                       CMTFPatternBot::Check(void);

  // Event Handlers
  void                       CMTFPatternBot::OnDeinit(const int reason);
  void                       CMTFPatternBot::OnTick(void);
  void                       CMTFPatternBot::OnTrade(void);
  void                       CMTFPatternBot::OnTimer(void);
  double                     CMTFPatternBot::OnTester(void);
  void                       CMTFPatternBot::OnBar(void);
  
  void                       CMTFPatternBot::OnOrderPlaced(ulong _order);
  void                       CMTFPatternBot::OnOrderModified(ulong _order);
  void                       CMTFPatternBot::OnOrderDeleted(ulong _order);
  void                       CMTFPatternBot::OnOrderExpired(ulong _order);
  void                       CMTFPatternBot::OnOrderTriggered(ulong _order);

  void                       CMTFPatternBot::OnPositionOpened(ulong _position, ulong _deal);
  void                       CMTFPatternBot::OnPositionStopLoss(ulong _position, ulong _deal);
  void                       CMTFPatternBot::OnPositionTakeProfit(ulong _position, ulong _deal);
  void                       CMTFPatternBot::OnPositionClosed(ulong _position, ulong _deal);
  void                       CMTFPatternBot::OnPositionCloseBy(ulong _position, ulong _deal);
  void                       CMTFPatternBot::OnPositionModified(ulong _position);  
  
  // Bot's logic
  void                       CMTFPatternBot::UpdateComment(const bool _ignore_interval = false);
  
  void                       CMTFPatternBot::UpdateDateInMqlDateTime(MqlDateTime& _dt_mql, datetime _dt);
  
  double                     CMTFPatternBot::CalcLot();
  double                     CMTFPatternBot::AdjustLot(double _lot);
  
  bool                       CMTFPatternBot::CheckFilter(const int _dir, const int _cnt, MqlRates& _rates[], double& _buf_ma[]);
  bool                       CMTFPatternBot::IsCurrWeekDayEnabled(CArrayString& _list);
  
  int                        CMTFPatternBot::GetSignal();
  ulong                      CMTFPatternBot::OpenPosOnSignal();
  bool                       CMTFPatternBot::ClosePosOnTime();
  bool                       CMTFPatternBot::CloseWrongDirPos(const int _dir);
  
  void                       CMTFPatternBot::Draw();
  
  void                       CMTFPatternBot::OnM1(void);
};

//+------------------------------------------------------------------+
//| Destructor
//+------------------------------------------------------------------+
void CMTFPatternBot::~CMTFPatternBot(void){
}

//+------------------------------------------------------------------+
//| Inits bot
//+------------------------------------------------------------------+
void CMTFPatternBot::InitChild() {
  // 01. Parse Signal Time interval
  SignalTime = StringToMqlDateTime(Inputs.SIG_TIM);
  SignalMinDate = StructToTime(SignalTime)-24*60*60;
  
  // 02. Parse Close Time
  CloseTime = StringToMqlDateTime(Inputs.EXT_TIM);
  CloseMinDate = StructToTime(CloseTime)-24*60*60;
  
  // 03. Week Day Allowed
  CDKString str;
  
  WeekDayAllowedLong.Clear();
  str.Assign(Inputs.FIL_DWA_LNG);
  str.Split(";", WeekDayAllowedLong);
  
  WeekDayAllowedShort.Clear();
  str.Assign(Inputs.FIL_DWA_SHT);
  str.Split(";", WeekDayAllowedShort);
  
  NextM1Time = TimeLocal();
}

//+------------------------------------------------------------------+
//| Check bot's params
//+------------------------------------------------------------------+
bool CMTFPatternBot::Check(void) {
  if(!CDKBaseBot<CMTFPatternBotInputs>::Check())
    return false;
    
  if(!Inputs.InitAndCheck()) {
    Logger.Critical(Inputs.LastErrorMessage, true);
    return false;
  }

  return true;
}

//+------------------------------------------------------------------+
//| OnDeinit Handler
//+------------------------------------------------------------------+
void CMTFPatternBot::OnDeinit(const int reason) {
}

//+------------------------------------------------------------------+
//| OnTick Handler
//+------------------------------------------------------------------+
void CMTFPatternBot::OnTick(void) {
  CDKBaseBot<CMTFPatternBotInputs>::OnTick(); // Check new bar and show comment
  
  // 03. Channels update
  bool need_update = false;

  // 06. Update comment
  if(need_update)
    UpdateComment(true);
}

//+------------------------------------------------------------------+
//| OnBar Handler
//+------------------------------------------------------------------+
void CMTFPatternBot::OnBar(void) {
}

//+------------------------------------------------------------------+
//| OnTrade Handler
//+------------------------------------------------------------------+
void CMTFPatternBot::OnTrade(void) {
  CDKBaseBot<CMTFPatternBotInputs>::OnTrade();
}

//+------------------------------------------------------------------+
//| OnTimer Handler
//+------------------------------------------------------------------+
void CMTFPatternBot::OnTimer(void) {
  OnM1();

  UpdateComment();
  CDKBaseBot<CMTFPatternBotInputs>::OnTimer();
}

//+------------------------------------------------------------------+
//| OnTester Handler
//+------------------------------------------------------------------+
double CMTFPatternBot::OnTester(void) {
  return 0;
}

void CMTFPatternBot::OnOrderPlaced(ulong _order){
  //Logger.Info(StringFormat("%s/%d", __FUNCTION__, __LINE__));
}

void CMTFPatternBot::OnOrderModified(ulong _order){
  //Logger.Info(StringFormat("%s/%d", __FUNCTION__, __LINE__));
}

void CMTFPatternBot::OnOrderDeleted(ulong _order){
  //Logger.Info(StringFormat("%s/%d", __FUNCTION__, __LINE__));
}

void CMTFPatternBot::OnOrderExpired(ulong _order){
  //Logger.Info(StringFormat("%s/%d", __FUNCTION__, __LINE__));
}

void CMTFPatternBot::OnOrderTriggered(ulong _order){
  //Logger.Info(StringFormat("%s/%d", __FUNCTION__, __LINE__));
}

void CMTFPatternBot::OnPositionTakeProfit(ulong _position, ulong _deal){
  //Logger.Info(StringFormat("%s/%d", __FUNCTION__, __LINE__));
}

void CMTFPatternBot::OnPositionClosed(ulong _position, ulong _deal){
  //Logger.Info(StringFormat("%s/%d", __FUNCTION__, __LINE__));
}

void CMTFPatternBot::OnPositionCloseBy(ulong _position, ulong _deal){
  //Logger.Info(StringFormat("%s/%d", __FUNCTION__, __LINE__));
}

void CMTFPatternBot::OnPositionModified(ulong _position){
  //Logger.Info(StringFormat("%s/%d", __FUNCTION__, __LINE__));
}  
  
//+------------------------------------------------------------------+
//| OnPositionOpened
//+------------------------------------------------------------------+
void CMTFPatternBot::OnPositionOpened(ulong _position, ulong _deal) {
  //Logger.Info(StringFormat("%s/%d", __FUNCTION__, __LINE__));
}

//+------------------------------------------------------------------+
//| OnStopLoss Handler
//+------------------------------------------------------------------+
void CMTFPatternBot::OnPositionStopLoss(ulong _position, ulong _deal) {
  //Logger.Info(StringFormat("%s/%d", __FUNCTION__, __LINE__));
}


//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Bot's logic
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//| Updates comment
//+------------------------------------------------------------------+
void CMTFPatternBot::UpdateComment(const bool _ignore_interval = false) {
  ClearComment();

  ShowComment(_ignore_interval);     
}

//+------------------------------------------------------------------+
//| Replaces date in _dt_mql using _dt
//+------------------------------------------------------------------+
void CMTFPatternBot::UpdateDateInMqlDateTime(MqlDateTime& _dt_mql, datetime _dt) {
  MqlDateTime dt_mql_src;
  TimeToStruct(_dt, dt_mql_src);
  
  _dt_mql.year = dt_mql_src.year;
  _dt_mql.mon = dt_mql_src.mon;
  _dt_mql.day = dt_mql_src.day;
}


//+------------------------------------------------------------------+
//| Checks price over/under ma filter for all bars
//+------------------------------------------------------------------+
bool CMTFPatternBot::CheckFilter(const int _dir, const int _cnt, MqlRates& _rates[], double& _buf_ma[]) {
  for(int i=1;i<_cnt;i++) 
    if((_dir > 0 && _rates[i].close < _buf_ma[i]) ||
       (_dir < 0 && _rates[i].close > _buf_ma[i])) {
      Logger.Info(LSF(StringFormat("SIGNAL_DIR=0; BAR0_DT=%s; CLOSE(0)=%s; MA(0)=%s; BAR%d_DT=%s; CLOSE(%d)=%s; MA(%d)=%s", 
                                   TimeToString(_rates[0].time), Sym.PriceFormat(_rates[0].close), Sym.PriceFormat(_buf_ma[0]),
                                   i, TimeToString(_rates[i].time), i, Sym.PriceFormat(_rates[i].close), i, Sym.PriceFormat(_buf_ma[i]))));       
      return false;
    }
    
  return true;
}

//+------------------------------------------------------------------+
//| Checks Signal
//| Returns:
//|   +1 - Long
//|   -1 - Short
//|   0 - No sig
//+------------------------------------------------------------------+
int CMTFPatternBot::GetSignal() {
  int dir = 0;
  
  int buf_cnt = MathMax((int)Inputs.SIG_DPT_LNG, (int)Inputs.SIG_DPT_SHT);
  buf_cnt = MathMax(buf_cnt, 1);
  
  MqlRates rates[]; ArraySetAsSeries(rates, true);
  if(CopyRates(Sym.Name(), TF, 0, buf_cnt, rates) < buf_cnt) {
    Logger.Error(LSF("CopyRates() error"));
    return 0;
  }
  
  double buf_ma[]; ArraySetAsSeries(buf_ma, true);
  if(CopyBuffer(Inputs.IndMAHndl, 0, 0, buf_cnt, buf_ma) < buf_cnt) {
    Logger.Error(LSF("CopyBuffer() error"));
    return 0;
  }
  
  dir = (rates[0].close > buf_ma[0]) ? +1 : -1;
  
  if((dir > 0 && !CheckFilter(dir, Inputs.SIG_DPT_LNG, rates, buf_ma)) || 
     (dir < 0 && !CheckFilter(dir, Inputs.SIG_DPT_SHT, rates, buf_ma)))
    return 0;
  
  Logger.Info(LSF(StringFormat("SIGNAL_DIR=%d; BAR0_DT=%s; CLOSE(0)=%s; MA(0)=%s; SIG_DPT_%s=%d", 
                               dir, 
                               TimeToString(rates[0].time), Sym.PriceFormat(rates[0].close), Sym.PriceFormat(buf_ma[0]), 
                               (dir > 0) ? "LNG" : "SHT",
                               (dir > 0) ? Inputs.SIG_DPT_LNG : Inputs.SIG_DPT_SHT))); 
  return dir;
}

//+------------------------------------------------------------------+
//| Calc lot size
//+------------------------------------------------------------------+
double CMTFPatternBot::CalcLot() {
  double lot = Inputs.ENT_LTV;
  if(Inputs.ENT_LTP == LOT_TYPE_DEPOSIT_PERCENT) {
    CAccountInfo acc;
    Sym.RefreshRates();
    double ask = Sym.Ask();
    if(ask <= 0) return 0;
    lot = acc.Balance() / ask * Inputs.ENT_LTV / 100;
    lot = Sym.NormalizeLot(lot);
    Logger.Info(LSF(StringFormat("LOT=%f; BALANCE=%0.2f; ENT_LTV=%0.1f%%; ASK=%s",
                                 lot, acc.Balance(), Inputs.ENT_LTV, Sym.PriceFormat(ask))));
  }
  
  return lot;
}

//+------------------------------------------------------------------+
//| Lot correction
//+------------------------------------------------------------------+
double CMTFPatternBot::AdjustLot(double _lot) {
  if(Inputs.ENT_LC_MOD == LOT_CORRECTION_MODE_VOLATILITY_RATIO) {
    Sym.RefreshRates();
    double ask = Sym.Ask();
  
    double atr_d1 = iHigh(Sym.Name(), PERIOD_D1, 0)-iLow(Sym.Name(), PERIOD_D1, 0);
    if(ask > 0)  {
      double atr_d1_perc = atr_d1/ask*100;
      int pwr = (int)(atr_d1_perc/Inputs.ENT_LC_VR_DPT);
      double ratio = MathPow(Inputs.ENT_LC_VR_LTR, pwr);
      _lot = _lot * ratio;
      Logger.Info(LSF(StringFormat("LOT=%f; ASK=%s; ATR(D1)=%s/%0.1f%%; PWR=%d; RATIO=%f",
                                   _lot, Sym.PriceFormat(ask), Sym.PriceFormat(atr_d1), atr_d1_perc, pwr, ratio)));
    }
  }
  
  return _lot;
}

//+------------------------------------------------------------------+
//| Check week day is enabled
//+------------------------------------------------------------------+
bool CMTFPatternBot::IsCurrWeekDayEnabled(CArrayString& _list) {
  MqlDateTime dt_mql_curr;
  TimeToStruct(TimeLocal(), dt_mql_curr);
  if(_list.SearchLinear(IntegerToString(dt_mql_curr.day_of_week)) < 0) {
    Logger.Info(LSF(StringFormat("FILTER: Week Day: WD=%d", 
                                  dt_mql_curr.day_of_week)));
    return false;
  }  

  return true;  
}

//+------------------------------------------------------------------+
//| Open pos on Signal
//+------------------------------------------------------------------+
ulong CMTFPatternBot::OpenPosOnSignal() {
  // 01. Check Time Allowed
  datetime dt_curr = TimeLocal();
  UpdateDateInMqlDateTime(SignalTime, dt_curr);
  if(!(dt_curr >= StructToTime(SignalTime) && dt_curr >= SignalMinDate))  {
    if(DEBUG >= Logger.Level)
      Logger.Debug(LSF(StringFormat("NO SIGNAL. Wrong time: ALLOWED_DT=%s", 
                                    TimeToString(StructToTime(SignalTime))
                                    )));
    return 0;
  }
  SignalMinDate = TimeBeginning(dt_curr+24*60*60, DATETIME_PART_DAY);

  // 02. Get Signal
  int dir = GetSignal();
  
  // 03. Close wrong dir pos
  CloseWrongDirPos(dir);

  if(dir == 0) return 0;
  
  // 04. Dir
  if((dir > 0 && Inputs.SIG_DIR == TRADE_DIR_SHORT) ||
     (dir < 0 && Inputs.SIG_DIR == TRADE_DIR_LONG)) {
    Logger.Info(LSF(StringFormat("NO SIGNAL: Dir is not allowed: DIR=%d", 
                                 dir)));
    return 0;
  }
  
  // 05. Skip by day week
  if((dir > 0 && !IsCurrWeekDayEnabled(WeekDayAllowedLong)) || 
     (dir < 0 && !IsCurrWeekDayEnabled(WeekDayAllowedShort))) 
    return 0;
  
  // 06. Skip entry if we have pos
  LoadMarketPos();
  if(Poses.Total() > 0) {
    Logger.Info(LSF(StringFormat("Signal skipped by same dir pos in market: POS_CNT=%d", Poses.Total())));
    return 0;
  }
  
  // 07. Open pos
  ulong ticket = 0;
  double lot = CalcLot();
  lot = AdjustLot(lot);
  
  string comment = StringFormat("%s: %s", Logger.Name, TimeToString(TimeLocal()));
  if(dir > 0) 
    ticket = Trade.Buy(lot, Sym.Name(), 0, 0, 0, comment);
  else
    ticket = Trade.Sell(lot, Sym.Name(), 0, 0, 0, comment);
  
  Logger.Assert(ticket > 0,
                LSF(StringFormat("RET_CODE=%d; TICKET=%I64u; DIR=%d",
                                 Trade.ResultRetcode(),
                                 ticket,
                                 dir)),
                WARN, ERROR);

  return ticket;
}

//+------------------------------------------------------------------+
//| Close all with wrong dir
//+------------------------------------------------------------------+
bool CMTFPatternBot::CloseWrongDirPos(const int _dir) {
  bool res = false;
  CDKPositionInfo pos;  
  for(int i=0;i<Poses.Total();i++){
    ulong ticket = Poses.At(i);
    if(!pos.SelectByTicket(ticket)) continue;
    
    if((pos.PositionType() == POSITION_TYPE_BUY  && _dir <= 0 && IsCurrWeekDayEnabled(WeekDayAllowedLong)) ||
       (pos.PositionType() == POSITION_TYPE_SELL && _dir >= 0 && IsCurrWeekDayEnabled(WeekDayAllowedShort))) {
      res = Trade.PositionClose(ticket) || res;
      Logger.Assert(res, 
                    LSF(StringFormat("RET_CODE=%d; TICKET=%I64u; POS_DIR=%d; SIG_DIR=%d",
                                     Trade.ResultRetcode(),
                                     ticket,
                                     PositionTypeToString(pos.PositionType()),
                                     _dir)),
                    WARN, ERROR);
    }
  }
  
  return res;
}

//+------------------------------------------------------------------+
//| Close all poses on time
//+------------------------------------------------------------------+
bool CMTFPatternBot::ClosePosOnTime() {
  if(Inputs.EXT_MOD == EXIT_MODE_NO)
    return false;

  // 01. Check Time Allowed
  datetime dt_curr = TimeLocal();
  UpdateDateInMqlDateTime(CloseTime, dt_curr);
  if(dt_curr < StructToTime(CloseTime) || dt_curr < CloseMinDate)  {
    if(DEBUG >= Logger.Level)
      Logger.Debug(LSF(StringFormat("CLOSING POS. Wrong time: CLOSE_DT=%s", 
                                    TimeToString(StructToTime(CloseTime)))));
     return false;
  }
  CloseMinDate = TimeBeginning(dt_curr+24*60*60, DATETIME_PART_DAY);
  
  if(Poses.Total() <= 0) return false;
  
  bool res = false;
  MqlDateTime dt_mql_curr;
  TimeToStruct(dt_curr, dt_mql_curr);
  MqlDateTime dt_mql_pos;
  CDKPositionInfo pos;
  for(int i=0;i<Poses.Total();i++) {
    long ticket = Poses.At(i);
    if(!pos.SelectByTicket(ticket)) continue;
    
    // Week day filter
    if((pos.PositionType() == POSITION_TYPE_BUY  && !IsCurrWeekDayEnabled(WeekDayAllowedLong)) ||
       (pos.PositionType() == POSITION_TYPE_SELL && !IsCurrWeekDayEnabled(WeekDayAllowedShort)))
       continue;
    
    // Skip pos of current day
    TimeToStruct(pos.Time(), dt_mql_pos);
    if(dt_mql_curr.day == dt_mql_pos.day) {
      Logger.Info(LSF(StringFormat("Today pos closing skipped: TICKET=%I64u; OPEN_DT=%s",
                                    ticket,
                                    TimeToString(pos.Time()))));
      continue;
    }
    
    // Skip profitable pos
    if(Inputs.EXT_MOD == EXIT_MODE_KEEP_PROFITABLE_POS && pos.Profit() > 0) {
      Logger.Info(LSF(StringFormat("Profitable pos closing skipped: TICKET=%I64u; PROFIT=%0.2f",
                                    ticket,
                                    pos.Profit())));
      continue;
    }
    
    res = Trade.PositionClose(ticket) || res;
  }
  
  return res;
}

void CMTFPatternBot::Draw() {

}

//+------------------------------------------------------------------+
//| OnM1 Handler
//+------------------------------------------------------------------+
void CMTFPatternBot::OnM1(void) {
  datetime dt_curr = TimeLocal();
  if(dt_curr < NextM1Time) return;
  NextM1Time = TimeBeginning(dt_curr + 60, DATETIME_PART_MIN);

  ClosePosOnTime();
  OpenPosOnSignal();
}

