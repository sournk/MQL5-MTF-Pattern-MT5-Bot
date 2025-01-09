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

enum ENUM_EXIT_MODE {
  EXIT_MODE_LTF = 0,    // LTF Bar Reverses
  EXIT_MODE_HTF = 1     // HTF Bar Reverses
};

enum ENUM_SIGNAL_MODE {
  ENUM_SIGNAL_BAR = 0,  // Bar
  ENUM_SIGNAL_MA = 1,   // MA
};


// PARSING AREA OF INPUT STRUCTURE == START == DO NOT REMOVE THIS COMMENT
struct CMTFPatternBotInputs {
  // input  group                    "1. ENTRY (ENT)"
  ENUM_MM_TYPE                ENT_LTP;                  // ENT_LTP: Lot Type // ENUM_MM_TYPE_FIXED_LOT
  double                      ENT_LTV;                  // ENT_LTV: Lot Type Value // 0.1(x > 0)

  // input  group                    "2. EXIT (EXT)"
  ENUM_EXIT_MODE              EXT_MOD;                  // EXT_MOD: Exit Mode // EXIT_MODE_LTF

  // input  group                    "3. SIGNAL (SIG)"
  ENUM_TRADE_DIR              SIG_DIR;                  // SIG_DIR: Signal Direction Allowed // TRADE_DIR_BOTH 
  ENUM_SIGNAL_MODE            SIG_MOD;                  // SIG_MOD: Signal Mode // ENUM_SIGNAL_BAR
  ENUM_TIMEFRAMES             SIG_HTF;                  // SIG_HTF: Higher Timeframe // PERIOD_M30
  ENUM_TIMEFRAMES             SIG_LTF;                  // SIG_LTF: Lower Timeframe // PERIOD_M5
  ENUM_MA_METHOD              SIG_MAM;                  // SIG_MAM: MA Method // MODE_EMA
  uint                        SIG_MAP;                  // SIG_MAP: MA Period // 9(x>0)
  

// PARSING AREA OF INPUT STRUCTURE == END == DO NOT REMOVE THIS COMMENT

  string LastErrorMessage;
  bool CMTFPatternBotInputs::InitAndCheck();
  bool CMTFPatternBotInputs::Init();
  bool CMTFPatternBotInputs::CheckBeforeInit();
  bool CMTFPatternBotInputs::CheckAfterInit();
  void CMTFPatternBotInputs::CMTFPatternBotInputs();
  
  
  // IND HNDLs
  int IndMAHTFHndl;
  int IndMALTFHndl;
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
  IndMAHTFHndl = iMA(Symbol(), SIG_HTF, SIG_MAP, 0, SIG_MAM, PRICE_CLOSE);
  IndMALTFHndl = iMA(Symbol(), SIG_LTF, SIG_MAP, 0, SIG_MAM, PRICE_CLOSE);
  return true;
}

//+------------------------------------------------------------------+
//| Check struc after Init
//+------------------------------------------------------------------+
bool CMTFPatternBotInputs::CheckAfterInit(){
  LastErrorMessage = "";
  if(IndMAHTFHndl < 0 || IndMALTFHndl < 0)
    LastErrorMessage = "MA indicator load failed";
  return LastErrorMessage == "";
}

// GENERATED CODE == START == DO NOT REMOVE THIS COMMENT

// input  group                    "1. ENTRY (ENT)"
// input  ENUM_LOT_TYPE             Inp_ENT_LTP                        = LOT_TYPE_DEPOSIT_PERCENT;             // ENT_LTP: Lot Type
// input  double                    Inp_ENT_LTV                        = 200.0;                                // ENT_LTV: Lot Type Value
// input  ENUM_LOT_CORRECTION_MODE  Inp_ENT_LC_MOD                     = LOT_CORRECTION_MODE_VOLATILITY_RATIO; // ENT_LC_MOD: Lot Correction by Volatility Enabled
// input  double                    Inp_ENT_LC_VR_DPT                  = 5.0;                                  // ENT_LC_VR_DPT: Daily price movement threshold, %
// input  double                    Inp_ENT_LC_VR_LTR                  = 0.5;                                  // ENT_LC_VR_LTR: Lot Ratio applied after ever 'ENT_LC_VR_DPT' reached

// input  group                    "2. EXIT (EXT)"
// input  ENUM_EXIT_MODE            Inp_EXT_MOD                        = EXIT_MODE_KEEP_PROFITABLE_POS;        // EXT_MOD: Exit Mode
// input  string                    Inp_EXT_TIM                        = "13:30";                              // EXT_TIM: Exit fixed Time

// input  group                    "3. SIGNAL (SIG)"
// input  string                    Inp_SIG_TIM                        = "13:30";                              // SIG_TIM: Signal Time Interval (e.g. "13:30")
// input  ENUM_TRADE_DIR            Inp_SIG_DIR                        = TRADE_DIR_BOTH;                       // SIG_DIR: Signal Direction Allowed
// input  ENUM_MA_METHOD            Inp_SIG_MOD                        = MODE_SMA;                             // SIG_MOD: MA Mode
// input  ENUM_TIMEFRAMES           Inp_SIG_TFR                        = PERIOD_M5;                            // SIG_TFR: MA Timeframe
// input  uint                      Inp_SIG_MAP                        = 42;                                   // SIG_MAP: MA Period
// input  uint                      Inp_SIG_DPT_LNG                    = 3;                                    // SIG_DPT_LNG: Depth for Long (0-off)
// input  uint                      Inp_SIG_DPT_SHT                    = 0;                                    // SIG_DPT_SHT: Depth for Short (0-off)

// input  group                    "4. FILTER (FIL)"
// input  string                    Inp_FIL_DWA_LNG                    = "1;2;3;4;5";                          // FIL_DWA_LNG: Days of Week allowed for Long (;-sep)
// input  string                    Inp_FIL_DWA_SHT                    = "1;2;3;4";                            // FIL_DWA_SHT: Days of Week allowed for Short (;-sep)

// CMTFPatternBotInputs inputs;
// inputs.ENT_LTP                   = Inp_ENT_LTP;                                                             // ENT_LTP: Lot Type
// inputs.ENT_LTV                   = Inp_ENT_LTV;                                                             // ENT_LTV: Lot Type Value
// inputs.ENT_LC_MOD                = Inp_ENT_LC_MOD;                                                          // ENT_LC_MOD: Lot Correction by Volatility Enabled
// inputs.ENT_LC_VR_DPT             = Inp_ENT_LC_VR_DPT;                                                       // ENT_LC_VR_DPT: Daily price movement threshold, %
// inputs.ENT_LC_VR_LTR             = Inp_ENT_LC_VR_LTR;                                                       // ENT_LC_VR_LTR: Lot Ratio applied after ever 'ENT_LC_VR_DPT' reached
// inputs.EXT_MOD                   = Inp_EXT_MOD;                                                             // EXT_MOD: Exit Mode
// inputs.EXT_TIM                   = Inp_EXT_TIM;                                                             // EXT_TIM: Exit fixed Time
// inputs.SIG_TIM                   = Inp_SIG_TIM;                                                             // SIG_TIM: Signal Time Interval (e.g. "13:30")
// inputs.SIG_DIR                   = Inp_SIG_DIR;                                                             // SIG_DIR: Signal Direction Allowed
// inputs.SIG_MOD                   = Inp_SIG_MOD;                                                             // SIG_MOD: MA Mode
// inputs.SIG_TFR                   = Inp_SIG_TFR;                                                             // SIG_TFR: MA Timeframe
// inputs.SIG_MAP                   = Inp_SIG_MAP;                                                             // SIG_MAP: MA Period
// inputs.SIG_DPT_LNG               = Inp_SIG_DPT_LNG;                                                         // SIG_DPT_LNG: Depth for Long (0-off)
// inputs.SIG_DPT_SHT               = Inp_SIG_DPT_SHT;                                                         // SIG_DPT_SHT: Depth for Short (0-off)
// inputs.FIL_DWA_LNG               = Inp_FIL_DWA_LNG;                                                         // FIL_DWA_LNG: Days of Week allowed for Long (;-sep)
// inputs.FIL_DWA_SHT               = Inp_FIL_DWA_SHT;                                                         // FIL_DWA_SHT: Days of Week allowed for Short (;-sep)


//+------------------------------------------------------------------+
//| Constructor
//+------------------------------------------------------------------+
void CMTFPatternBotInputs::CMTFPatternBotInputs():
       ENT_LTP(LOT_TYPE_DEPOSIT_PERCENT),
       ENT_LTV(200.0),
       ENT_LC_MOD(LOT_CORRECTION_MODE_VOLATILITY_RATIO),
       ENT_LC_VR_DPT(5.0),
       ENT_LC_VR_LTR(0.5),
       EXT_MOD(EXIT_MODE_KEEP_PROFITABLE_POS),
       EXT_TIM("13:30"),
       SIG_TIM("13:30"),
       SIG_DIR(TRADE_DIR_BOTH),
       SIG_MOD(MODE_SMA),
       SIG_TFR(PERIOD_M5),
       SIG_MAP(42),
       SIG_DPT_LNG(3),
       FIL_DWA_LNG("1;2;3;4;5"),
       FIL_DWA_SHT("1;2;3;4"){

};


//+------------------------------------------------------------------+
//| Check struc before Init
//+------------------------------------------------------------------+
bool CMTFPatternBotInputs::CheckBeforeInit() {
  LastErrorMessage = "";
  if(!(ENT_LTV > 0)) LastErrorMessage = "'ENT_LTV' must satisfy condition: ENT_LTV > 0";
  if(!(ENT_LC_MOD == LOT_CORRECTION_MODE_VOLATILITY_RATIO && ENT_LC_VR_DPT > 0.0)) LastErrorMessage = "'ENT_LC_VR_DPT' must satisfy condition: ENT_LC_MOD == LOT_CORRECTION_MODE_VOLATILITY_RATIO && ENT_LC_VR_DPT > 0.0";
  if(!(ENT_LC_MOD == LOT_CORRECTION_MODE_VOLATILITY_RATIO && ENT_LC_VR_LTR > 0.0)) LastErrorMessage = "'ENT_LC_VR_LTR' must satisfy condition: ENT_LC_MOD == LOT_CORRECTION_MODE_VOLATILITY_RATIO && ENT_LC_VR_LTR > 0.0";
  if(!(EXT_TIM != "")) LastErrorMessage = "'EXT_TIM' must satisfy condition: EXT_TIM != """;
  if(!(SIG_TIM != "")) LastErrorMessage = "'SIG_TIM' must satisfy condition: SIG_TIM != """;
  if(!(SIG_MAP>0)) LastErrorMessage = "'SIG_MAP' must satisfy condition: SIG_MAP>0";

  return LastErrorMessage == "";
}
// GENERATED CODE == END == DO NOT REMOVE THIS COMMENT