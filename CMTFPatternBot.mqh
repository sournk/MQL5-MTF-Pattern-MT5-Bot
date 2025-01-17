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

#include <ChartObjects\ChartObjectsShapes.mqh>
//#include <ChartObjects\ChartObjectsLines.mqh>
//#include <ChartObjects\ChartObjectsArrows.mqh> 

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
  
  // Bot's logic
  void                       CMTFPatternBot::UpdateComment(const bool _ignore_interval = false);
  
  
  int                        CMTFPatternBot::GetMqlRateDir(MqlRates& _rate);
  MqlRates                   CMTFPatternBot::GetBarMqlRate(const ENUM_TIMEFRAMES _tf, const int _bar_idx);
  
  bool                       CMTFPatternBot::IsFilteredOut(const int _dir);
  int                        CMTFPatternBot::GetSignal(MqlRates& _htf, MqlRates& _ltf);
  ulong                      CMTFPatternBot::ClosePosOnReversedSignal(const int _dir);
  ulong                      CMTFPatternBot::OpenPos(const int _dir);
  
  void                       CMTFPatternBot::Draw();
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

  if(Period() != Inputs.SIG_LTF) {
    Logger.Critical(StringFormat("Run the bot on SIG_LTF=%s", TimeframeToString(Inputs.SIG_LTF)), true);
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
  // 02. Get Sig
  MqlRates htf_0 = GetBarMqlRate(Inputs.SIG_HTF, 0);
  MqlRates ltf_0 = GetBarMqlRate(Inputs.SIG_LTF, 0);
  MqlRates ltf_1 = GetBarMqlRate(Inputs.SIG_LTF, 1);
  int dir = GetSignal(htf_0, ltf_1);
  
  // 03. Close pos on reversal
  ClosePosOnReversedSignal(GetMqlRateDir(ltf_1));  
  
  
  // 04. No sig
  if(dir == 0) return;
  
  // 04. Sig Filter
  if(IsFilteredOut(dir)) return;
  
  // 05. We have pos ==> no new open
  LoadMarket();
  if(Poses.Total() > 0) return;
  
  // 06. It's 1st bar on LTF ==> No dir yet ==> Skip new open
  int htf_0_idx = iBarShift(Sym.Name(), Inputs.SIG_LTF, htf_0.time);
  int ltf_0_idx = iBarShift(Sym.Name(), Inputs.SIG_LTF, ltf_0.time);
  if(Inputs.SIG_MOD == ENUM_SIGNAL_LTF_HTF)
    if(htf_0_idx == ltf_0_idx) {
      Logger.Debug(LSF(StringFormat("Skipped first LTF bar in HTF: LTF(%s)", TimeToString(ltf_0.time))));
      return;
    }
  
  // 07. Check new bar only filter 
  if(Inputs.SIG_NBO && MathAbs(ltf_0_idx-htf_0_idx) > 1) {
    Logger.Debug(LSF(StringFormat("Skipped LTF bar not new HTF: LTF(%s)", TimeToString(ltf_0.time))));
    return;
  }  

  // 08. Open pos
  OpenPos(dir);  
  
  // 09. Draw
  Draw();  
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
  UpdateComment();
  CDKBaseBot<CMTFPatternBotInputs>::OnTimer();
}

//+------------------------------------------------------------------+
//| OnTester Handler
//+------------------------------------------------------------------+
double CMTFPatternBot::OnTester(void) {
  return 0;
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
//| Get Bar last dir 
//+------------------------------------------------------------------+
int CMTFPatternBot::GetMqlRateDir(MqlRates& _rate) {
  if(_rate.open < _rate.close) return +1;
  if(_rate.open > _rate.close) return -1;
  return 0;
}

//+------------------------------------------------------------------+
//| Get Bar last dir 
//+------------------------------------------------------------------+
MqlRates CMTFPatternBot::GetBarMqlRate(const ENUM_TIMEFRAMES _tf, const int _bar_idx) {
  MqlRates res_rate;
  res_rate.close = 0;
  res_rate.open = 0;
  res_rate.time = 0;
  
  MqlRates rates[]; ArraySetAsSeries(rates, true);
  if(CopyRates(Sym.Name(), _tf, _bar_idx, 1, rates) < 1) {
    Logger.Error(LSF(StringFormat("CopyRates(%s) error", TimeframeToString(_tf))));
    return res_rate;
  }
  
  return rates[0];
}

//+------------------------------------------------------------------+
//| Checks Signal
//| Returns:
//|   +1 - Long
//|   -1 - Short
//|    0 - No sig
//+------------------------------------------------------------------+
int CMTFPatternBot::GetSignal(MqlRates& _htf, MqlRates& _ltf) {
  int dir = 0;
  
  double ma_buf[]; ArraySetAsSeries(ma_buf, true); 
  if(CopyBuffer(Inputs.IndMAHndl, 0, 1, 2, ma_buf) < 2) {
    Logger.Error(LSF("CopyBuffer() error"));
    return 0;
  }


  if(Inputs.SIG_MOD == ENUM_SIGNAL_LTF_HTF) 
    if(GetMqlRateDir(_htf) == GetMqlRateDir(_ltf)) 
      dir = GetMqlRateDir(_htf);
  
  if(Inputs.SIG_MOD == ENUM_SIGNAL_LTF_ONLY){
    if(ma_buf[0] > ma_buf[1]) dir = +1;
    if(ma_buf[0] < ma_buf[1]) dir = -1;
  }
      
  Logger.Assert(dir != 0,
                LSF(StringFormat("DIR=%d; MODE=%s; HTF(%s)=%d; LTF(%s)=%d; MA(1)=%s; MA(0)=%s",
                                 dir,
                                 EnumToString(Inputs.SIG_MOD),
                                 TimeToString(_htf.time), GetMqlRateDir(_htf),
                                 TimeToString(_ltf.time), GetMqlRateDir(_ltf),
                                 Sym.PriceFormat(ma_buf[1]), Sym.PriceFormat(ma_buf[0]))),
                INFO, DEBUG);
 
  return dir;
}

//+------------------------------------------------------------------+
//| Close pos on reversed signal
//+------------------------------------------------------------------+
ulong CMTFPatternBot::ClosePosOnReversedSignal(const int _dir) {
  if(Poses.Total() <= 0) return 0;
  
  bool res = false;
  ulong ticket = 0;
  
  for(int i=0;i<Poses.Total();i++) {
    ticket = Poses.At(i);
    CDKPositionInfo pos;
    if(pos.SelectByTicket(ticket))
      if((pos.PositionType() == POSITION_TYPE_BUY  && _dir < 0) ||
         (pos.PositionType() == POSITION_TYPE_SELL && _dir > 0)) {
        res = Trade.PositionClose(ticket);
        Logger.Assert(res,
                      LSF(StringFormat("POS_NUM=%d; RET_CODE=%d; TICKET=I64u; KEEP_POS_DIR=%d",
                                       i,
                                       Trade.ResultRetcode(),
                                       ticket,
                                       _dir)),
                      WARN, ERROR);
      }
  }
  
  return (res) ? ticket : 0;
}

//+------------------------------------------------------------------+
//| Open pos on Signal
//+------------------------------------------------------------------+
ulong CMTFPatternBot::OpenPos(const int _dir) {
  ulong ticket = 0;
  double lot = Inputs.ENT_LTV;
  datetime ltf_dt = iTime(Sym.Name(), Inputs.SIG_LTF, 0);
  
  for(int i=1;i<=(int)Inputs.ENT_CNT;i++)    {     
    string comment = StringFormat("%s_%s_%d", Logger.Name, TimeToString(ltf_dt), i);
    if(_dir > 0) 
      ticket = Trade.Buy(lot, Sym.Name(), 0, 0, 0, comment);
    else
      ticket = Trade.Sell(lot, Sym.Name(), 0, 0, 0, comment);
    
    Logger.Assert(ticket > 0,
                  LSF(StringFormat("POS_NUM=%d; RET_CODE=%d; TICKET=%I64u; DIR=%d",
                                   i,
                                   Trade.ResultRetcode(),
                                   ticket,
                                   _dir)),
                  WARN, ERROR);
  }

  return ticket;
}

//+------------------------------------------------------------------+
//| Draw
//+------------------------------------------------------------------+
void CMTFPatternBot::Draw() {
  if(!Inputs.GUI_ENB) return;
  
  CChartObjectRectangle rec;
  double htf_o = iOpen(Sym.Name(), Inputs.SIG_HTF, 0);
  double htf_c = iClose(Sym.Name(), Inputs.SIG_HTF, 0);
  datetime ltf_dt = iTime(Sym.Name(), Inputs.SIG_LTF, 0);
  string name = StringFormat("%s_HTF_BAR_AT_%s", Logger.Name, TimeToString(ltf_dt));
  rec.Create(0, name, 0,
             iTime(Sym.Name(), Inputs.SIG_HTF, 0),
             htf_o,
             TimeCurrent(),
             htf_c);
  rec.Color((htf_o<=htf_c) ? Inputs.GUI_CLR_LNG : Inputs.GUI_CLR_SHT);
  rec.Fill(Inputs.GUI_BFL);
  rec.Detach();  
}

//+------------------------------------------------------------------+
//| Check Filter
//+------------------------------------------------------------------+
bool CMTFPatternBot::IsFilteredOut(const int _dir) {
  if(!Inputs.FIL_ENB) return false;
  
  double buf[]; ArraySetAsSeries(buf, true);
  int cnt = 3;
  if(CopyBuffer(Inputs.IndMAHndl, 0, 0, cnt, buf) < cnt) {
    Logger.Error(LSF("CopyBuffer() error"));
    return true;
  }
  
  bool res = false;
  if((_dir > 0 && buf[0] < buf[2]) ||
     (_dir < 0 && buf[0] > buf[2])) 
    res = true;
  
  datetime dt = iTime(Sym.Name(), Inputs.SIG_LTF, 0);
  Logger.Info(LSF(StringFormat("FILTER=%s; LTF_DT=%s; DIR=%d; MA[-2]=%s %s MA[0]=%s",
                               (res) ? "OUT" : "PASS",
                               TimeToString(dt),
                               _dir,
                               Sym.PriceFormat(buf[2]),
                               (buf[2] > buf[0]) ? ">" : "<=",
                               Sym.PriceFormat(buf[0]))));
  
  return res;
}