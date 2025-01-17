//+------------------------------------------------------------------+
//|                                            CMTFPatternInputs.mqh |
//|                                                  Denis Kislitsyn |
//|                                             https://kislitsyn.me |
//+------------------------------------------------------------------+

#include "Include\DKStdLib\Common\DKStdLib.mqh"

enum ENUM_TRADE_DIR {
  TRADE_DIR_BOTH = 0,   // Both
  TRADE_DIR_LONG = +1,  // Long
  TRADE_DIR_SHORT = -1, // Short
};

enum ENUM_SIGNAL_MODE {
  ENUM_SIGNAL_LTF_HTF  = 0,   // LTF & HTF
  ENUM_SIGNAL_LTF_ONLY = 1,   // LFT Only
};


// PARSING AREA OF INPUT STRUCTURE == START == DO NOT REMOVE THIS COMMENT
struct CMTFPatternBotInputs {
  // input  group                    "1. ENTRY (ENT)"
  uint                        ENT_CNT;                  // ENT_CNT: Pos number open on signal // 1(x>0)
  double                      ENT_LTV;                  // ENT_LTV: Pos Lot Value // 0.1(x > 0)

  // input  group                    "2. SIGNAL (SIG)"
  ENUM_TRADE_DIR              SIG_DIR;                  // SIG_DIR: Signal Direction Allowed // TRADE_DIR_BOTH 
  ENUM_SIGNAL_MODE            SIG_MOD;                  // SIG_MOD: Signal Mode // ENUM_SIGNAL_LTF_ONLY
  bool                        SIG_NBO;                  // SIG_NBO: Signal on New Bar Only // true
  ENUM_TIMEFRAMES             SIG_HTF;                  // SIG_HTF: Higher Timeframe // PERIOD_M30(x>SIG_LTF)
  ENUM_TIMEFRAMES             SIG_LTF;                  // SIG_LTF: Lower Timeframe // PERIOD_M5(x<SIG_HTF)

  // input  group                    "3. FILTER (FIL)"
  bool                        FIL_ENB;                  // FIL_ENB: Filter Enabled // true
  ENUM_MA_METHOD              FIL_MAM;                  // FIL_MAM: MA Method // MODE_EMA
  uint                        FIL_MAP;                  // FIL_MAP: MA Period  // 9
  

  
  // input  group                    "4. GUI"
  bool                         GUI_ENB;                  // GUI_ENB: Draw HTF bar Enabled // true
  color                        GUI_CLR_LNG;              // GUI_CLR_LNG: Color for Long // clrGreen
  color                        GUI_CLR_SHT;              // GUI_CLR_SHT: Color for Short // clrRed
  bool                         GUI_BFL;                  // GUI_BFL: Fill Bar // true
 
 
// PARSING AREA OF INPUT STRUCTURE == END == DO NOT REMOVE THIS COMMENT

  string LastErrorMessage;
  bool CMTFPatternBotInputs::InitAndCheck();
  bool CMTFPatternBotInputs::Init();
  bool CMTFPatternBotInputs::CheckBeforeInit();
  bool CMTFPatternBotInputs::CheckAfterInit();
  void CMTFPatternBotInputs::CMTFPatternBotInputs();
  
  
  // IND HNDLs
  int IndMAHndl;
};

//+------------------------------------------------------------------+
//| Init struc and Check values
//+------------------------------------------------------------------+
bool CMTFPatternBotInputs::InitAndCheck(){
  LastErrorMessage = "";

  if (!CheckBeforeInit())
    return false;

  if (!Init())
  {
    LastErrorMessage = "Input.Init() failed";
    return false;
  }

  return CheckAfterInit();
}

//+------------------------------------------------------------------+
//| Init struc
//+------------------------------------------------------------------+
bool CMTFPatternBotInputs::Init(){
  IndMAHndl = iMA(Symbol(), SIG_LTF, FIL_MAP, 0, FIL_MAM, PRICE_CLOSE);
  return true;
}

//+------------------------------------------------------------------+
//| Check struc after Init
//+------------------------------------------------------------------+
bool CMTFPatternBotInputs::CheckAfterInit(){
  LastErrorMessage = "";
  if(IndMAHndl < 0)
    LastErrorMessage = "MA indicator load failed";
  return LastErrorMessage == "";
}

// GENERATED CODE == START == DO NOT REMOVE THIS COMMENT

// input  group                    "1. ENTRY (ENT)"
// input  uint                      Inp_ENT_CNT                        = 1;               // ENT_CNT: Pos number open on signal
// input  double                    Inp_ENT_LTV                        = 0.1;             // ENT_LTV: Pos Lot Value

// input  group                    "2. SIGNAL (SIG)"
// input  ENUM_TRADE_DIR            Inp_SIG_DIR                        = TRADE_DIR_BOTH;  // SIG_DIR: Signal Direction Allowed
// input  ENUM_SIGNAL_MODE          Inp_SIG_MOD                        = ENUM_SIGNAL_LTF_ONLY; // SIG_MOD: Signal Mode
// input  bool                      Inp_SIG_NBO                        = true;            // SIG_NBO: Signal on New Bar Only
// input  ENUM_TIMEFRAMES           Inp_SIG_HTF                        = PERIOD_M30;      // SIG_HTF: Higher Timeframe
// input  ENUM_TIMEFRAMES           Inp_SIG_LTF                        = PERIOD_M5;       // SIG_LTF: Lower Timeframe

// input  group                    "3. FILTER (FIL)"
// input  bool                      Inp_FIL_ENB                        = true;            // FIL_ENB: Filter Enabled
// input  ENUM_MA_METHOD            Inp_FIL_MAM                        = MODE_EMA;        // FIL_MAM: MA Method
// input  uint                      Inp_FIL_MAP                        = 9;               // FIL_MAP: MA Period

// input  group                    "4. GUI"
// input  bool                      Inp_GUI_ENB                        = true;            // GUI_ENB: Draw HTF bar Enabled
// input  color                     Inp_GUI_CLR_LNG                    = clrGreen;        // GUI_CLR_LNG: Color for Long
// input  color                     Inp_GUI_CLR_SHT                    = clrRed;          // GUI_CLR_SHT: Color for Short
// input  bool                      Inp_GUI_BFL                        = true;            // GUI_BFL: Fill Bar

// CMTFPatternBotInputs inputs;
// inputs.ENT_CNT                   = Inp_ENT_CNT;                                        // ENT_CNT: Pos number open on signal
// inputs.ENT_LTV                   = Inp_ENT_LTV;                                        // ENT_LTV: Pos Lot Value
// inputs.SIG_DIR                   = Inp_SIG_DIR;                                        // SIG_DIR: Signal Direction Allowed
// inputs.SIG_MOD                   = Inp_SIG_MOD;                                        // SIG_MOD: Signal Mode
// inputs.SIG_NBO                   = Inp_SIG_NBO;                                        // SIG_NBO: Signal on New Bar Only
// inputs.SIG_HTF                   = Inp_SIG_HTF;                                        // SIG_HTF: Higher Timeframe
// inputs.SIG_LTF                   = Inp_SIG_LTF;                                        // SIG_LTF: Lower Timeframe
// inputs.FIL_ENB                   = Inp_FIL_ENB;                                        // FIL_ENB: Filter Enabled
// inputs.FIL_MAM                   = Inp_FIL_MAM;                                        // FIL_MAM: MA Method
// inputs.FIL_MAP                   = Inp_FIL_MAP;                                        // FIL_MAP: MA Period
// inputs.GUI_ENB                   = Inp_GUI_ENB;                                        // GUI_ENB: Draw HTF bar Enabled
// inputs.GUI_CLR_LNG               = Inp_GUI_CLR_LNG;                                    // GUI_CLR_LNG: Color for Long
// inputs.GUI_CLR_SHT               = Inp_GUI_CLR_SHT;                                    // GUI_CLR_SHT: Color for Short
// inputs.GUI_BFL                   = Inp_GUI_BFL;                                        // GUI_BFL: Fill Bar


//+------------------------------------------------------------------+
//| Constructor
//+------------------------------------------------------------------+
void CMTFPatternBotInputs::CMTFPatternBotInputs():
       ENT_CNT(1),
       ENT_LTV(0.1),
       SIG_DIR(TRADE_DIR_BOTH),
       SIG_MOD(ENUM_SIGNAL_LTF_ONLY),
       SIG_NBO(true),
       SIG_HTF(PERIOD_M30),
       SIG_LTF(PERIOD_M5),
       FIL_ENB(true),
       FIL_MAM(MODE_EMA),
       FIL_MAP(9),
       GUI_ENB(true),
       GUI_CLR_LNG(clrGreen),
       GUI_CLR_SHT(clrRed),
       GUI_BFL(true){

};


//+------------------------------------------------------------------+
//| Check struc before Init
//+------------------------------------------------------------------+
bool CMTFPatternBotInputs::CheckBeforeInit() {
  LastErrorMessage = "";
  if(!(ENT_CNT>0)) LastErrorMessage = "'ENT_CNT' must satisfy condition: ENT_CNT>0";
  if(!(ENT_LTV > 0)) LastErrorMessage = "'ENT_LTV' must satisfy condition: ENT_LTV > 0";
  if(!(SIG_HTF>SIG_LTF)) LastErrorMessage = "'SIG_HTF' must satisfy condition: SIG_HTF>SIG_LTF";
  if(!(SIG_LTF<SIG_HTF)) LastErrorMessage = "'SIG_LTF' must satisfy condition: SIG_LTF<SIG_HTF";

  return LastErrorMessage == "";
}
// GENERATED CODE == END == DO NOT REMOVE THIS COMMENT