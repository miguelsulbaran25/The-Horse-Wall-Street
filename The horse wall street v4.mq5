//+------------------------------------------------------------------+
//|                                        The Horse Wall Street.mq5 |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.02"
#include <Trade/Trade.mqh>
//+------------------------------------------------------------------+
//| Inputs                                                           |
//+------------------------------------------------------------------+
input group "==== Gestion ===="
input int InpMagicNumber = 123456;                    // Magic Number para identificar las órdenes del EA
input bool UseCustomBalance = false;                  // Activar o desactivar el balance personalizado
input int  InpBalance = 1000;                        // Balance personalizado
enum LOT_MODE_ENUM{
      LOT_MODE_FIXED,                     //por lote
      LOT_MODE_MONEY,                     //por dinero
      LOT_MODE_PCT_ACCOUNT                //por % de dinero
};
input LOT_MODE_ENUM InpLotMode   = LOT_MODE_FIXED; //modo de gestion
input double InpPercent = 3;                          // lotaje/dinero/porcentaje
input group "==== Entradas Generales ===="
input int MaxSpread = 2;                              // Límite máximo de spread en puntos
input int InpTp = 200;                                // Puntos de Take Profit
input int InpSl = 200;                                // Puntos de Stop Loss
input group "==== Remontar la perdida ===="
input bool     EnableLotIncrease = false;             // Activar/Desactivar incremento de lotaje tras pérdidas
input double   LotIncrement = 0.02;                   // incremento dependiendo del modo de gestion colocado
input group "==== Break Even + Trailing stop ===="
input bool        EnableTrailingStop = true;          // Activar/Desactivar el Trailing Stop
input int         Break_after_pts = 200;              // Puntos para activar el break even
input int         Break_at_pts = 50;                  // Puntos para mover el SL para break even
input int         InpTrailingStop = 250;              // Puntos para que se active el trailing stop
input int         TslPoints = 150;                    // Distancia SL con trailing
input int         InpFollowPoints = 10;               // Puntos que debe avanzar el precio para mover el SL
input group "==== Break even por niveles ===="
input bool     InpBreakEven         = true;           // Activar/Desactivar Break Even
input int      InpBreakEvenDistance = 50;             // Distancia de break even en puntos
input int      InpBreakEventp1      = 200;            // Puntos de TP1
input int      InpBreakEventp2      = 300;            // Puntos de TP2
input int      InpBreakEventp3      = 400;            // Puntos de TP3
input group "==== Cierre de Operaciones ===="
input bool InpCloseAtEnd = false;                     // Cerrar todas las posiciones a final de tiempo
input group "==== Operaciones en contra ===="
input bool  InpCounterOperation = false;              // activar o desactivar operaciones en contra
input int InpSellOrderDistance = 50;                  // Distancia para la venta en contra de la compra
input int InpBuyOrderDistance = 50;                   // Distancia para la compra en contra de la venta
input group "==== Periodo de Tiempo ===="
enum BotMode
{
    MODE_NORMAL,                                      // Modo normal 
    MODE_INVERTED                                     // Modo invertido
};
input BotMode InpBotMode = MODE_NORMAL;               // Colocacion de las ordenes
input bool EnableOrderCleanup = false;                // Activar/desactivar modo un solo lado
input int InpBarsToAnalyze = 200;                     // Cantidad de velas a analizar
input int ExpirationsBars = 100;                      // Número de barras para expiración de órdenes
input int OrderDiskPoints = 100;                      // Puntos de separación para órdenes
input int BarsN = 5;                                  // Numero de barras a esperar para colocar proxima orden
input int SHInput = 0;                                // Hora de Inicio de operación (0-23)
input int EHInput = 0;                                // Hora de Fin de operación (0-23)
string TradingenabledComm = "";
input group "==== filtro de ordenes ===="
enum ModeType
{
    MODE_INCREASE = 0,                                 // Aumentar maximo y minimo
    MODE_DECREASE = 1                                  // Disminuir maximo y minimo
};

input ModeType InpMode = MODE_INCREASE;               // Modo de ajuste (Aumentar o Disminuir)
input int InpPoints = 0;                              // Distancia de puntos para mover las órdenes
input group "==== filtro de noticias ===="
input bool NewsFilteron = true;                       // activar o desactivar el filtro de noticias
input string KeyNews = "BCB;NFP;JOLTS;Nonfarm;PMI;Retail;GDP;Confidence;Interest;Rate"; // palabras clave para identificar noticias
input string NewsCurrencies = "USD;GBP;JPY;BRL";      // monedas relacionadas con las noticias
input int    DaysNewsLookup   = 100;                  // número de días para buscar noticias
input int    StopBeforeMin    = 15;                   // detener el trading antes de la noticia (en minutos)
input int    StartTradingMin   = 15;                  // reanudar el trading después de la noticia (en minutos)
bool        TrDisableNews     = false;                // variable para indicar si el trading está deshabilitado debido a las noticias
input group "====Filtro Rsi ===="
input bool     RSIFILteron       = false;             // Activar o desactivar el filtro basado en el indicador RSI
input ENUM_TIMEFRAMES   RSITimeframe = PERIOD_H1;     // Marco de tiempo utilizado para el cálculo del RSI
input int   RSIlowerlvl       = 20;                   // Nivel inferior del RSI para identificar sobreventa
input int RSIupperlvl         = 80;                   // Nivel superior del RSI para identificar sobrecompra
input int   RSI__MA           = 14;                   // Período de cálculo para el RSI
input ENUM_APPLIED_PRICE   RSI_AppPrice = PRICE_MEDIAN; // Precio aplicado para el RSI 
input group "====Filtro Media Movil ===="
input bool  MAFilterOn     = false;                   // Activar o desactivar el filtro basado en la media móvil
input ENUM_TIMEFRAMES   MATimeframe   = PERIOD_H4;    // Marco de tiempo utilizado para el cálculo de la media móvil
input double PctPricefromMa      = 3;                 // Porcentaje de distancia entre el precio y la media móvil 
input int   MA_period            = 200;               // Período utilizado para el cálculo de la media móvil
input ENUM_MA_METHOD    MA_Mode = MODE_EMA;           // Método de la media móvil (SMA, EMA, SMMA, LWMA)
input ENUM_APPLIED_PRICE   MA_AppPrice = PRICE_MEDIAN; // Precio aplicado para el cálculo de la media móvil
input group "==== Personalización ===="
input string TradeComment = "Comentario del EA";      // Comentario en las órdenes del EA
input bool  HideIndicators = true;                    // Ocultar indicadores en el gráfico cuando se activa esta opción
input color    InpColorLevels = clrBlue;              // Color de los niveles de take profit
input bool EnablePanel = true;                        // activar o desactivar panel grafico
input color panel_color = clrDarkSlateGray;           // Color del panel
input color panel_text =  clrDarkSlateGray;           // Color texto del panel
input color InpHourStar    = clrGreen;                // color linea hora de inicio
input color InpEndTime     = clrBlue;                 // color linea hora fin
 
int panel_width = 250;   
int panel_height = 100;  
int panel_x = 10;        
int panel_y = 20;
// Variables generales
CTrade trade;           // Objeto para operaciones de trading
CPositionInfo pos;      // Objeto para información de posiciones
COrderInfo ord;         // Objeto para información de órdenes
ushort sep_code;
string Newstoavoid[];
datetime LastNewsAvoided;
int handleRSI = -1; 
int handleMovAvg = -1;
double initial_balance = 0;  // Balance inicial
string balance_text = "";    // Texto del balance 
bool  Tradingenabled = true;
double lastLotSize = 0;               // Tamaño del lote de la última operación
bool lastTradeLost = false;           // Indicador de si la última operación fue una pérdida
int sellOrderCounter = 0; // Variable global para el contador de órdenes de venta
int buyOrderCounter = 0; // Variable global para el contador de órdenes de compra   

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{   
   CreatePanel(); // crear panel grafico
   DrawVerticalLines(); // Dibujo de líneas para la hora 

   // Verificar las entradas del usuario
   if (!CheckInputs())
   {
      return INIT_PARAMETERS_INCORRECT;
   }
   
   // Configurar Magic Number
   trade.SetExpertMagicNumber(InpMagicNumber);
   
   // Desactivar la cuadrícula en el gráfico
   ChartSetInteger(0, CHART_SHOW_GRID, false);
   
   // Opción para ocultar indicadores en el tester
   if (HideIndicators == true) 
      TesterHideIndicators(true);
   
   // Inicializar el RSI solo si está activado
   if (RSIFILteron)
   {
      handleRSI = iRSI(_Symbol, RSITimeframe, RSI__MA, RSI_AppPrice);
      if (handleRSI == INVALID_HANDLE)
      {
         Print("Error al inicializar el RSI");
         return INIT_FAILED;
      }
   }
   
   // Inicializar la Media Móvil solo si está activada
   if (MAFilterOn)
   {
      handleMovAvg = iMA(_Symbol, MATimeframe, MA_period, 0, MA_Mode, MA_AppPrice);
      if (handleMovAvg == INVALID_HANDLE)
      {
         Print("Error al inicializar la Media Móvil");
         return INIT_FAILED;
      }
   }
   
   // Guardamos el balance inicial de la cuenta
   initial_balance = AccountInfoDouble(ACCOUNT_BALANCE);
   return(INIT_SUCCEEDED); // Indica que la inicialización fue exitosa
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   // Nombre del panel y sus elementos asociados
    string panel_name = "PanelGrafico";
    string balance_text_name = "BalanceText";
    string trade_stats_text_name = "TradeStatsText";

    // Elimina el panel y sus elementos del gráfico
    ObjectDelete(0, panel_name);
    ObjectDelete(0, balance_text_name);
    ObjectDelete(0, trade_stats_text_name);
    
    // Liberar los recursos de los indicadores si se usaron
   if (handleRSI != -1)
   {
      IndicatorRelease(handleRSI);
      handleRSI = -1;
   }
   if (handleMovAvg != -1)
   {
      IndicatorRelease(handleMovAvg);
      handleMovAvg = -1;
   }
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{  
   CheckActivatedOrders();//funcion modalidad un solo lado
   
   DetectAndPlaceSellOrder();// funcion para operacion en contra de la compra
   
   DetectAndPlaceBuyOrder(); // funcion para operacion en contra de la venta 
   
   DrawVerticalLines(); // dibujo de lineas para la hora
   
   UpdateLastTradeStatus(); // funcion incremento de lotaje
   
   UpdateBalanceText();// Actualizar el texto del balance
    
   UpdateBreakEvenLevels();// break even leves
   
   ManageBreakEvenAndTrailingStop();// break even + trailing stop

   if (!IsNewBar()) return;
   
   if (HideIndicators == true) 
    TesterHideIndicators(true);

   if (RSIFILteron) {
       handleRSI = iRSI(_Symbol, RSITimeframe, RSI__MA, RSI_AppPrice);
   }
   
   if (MAFilterOn) {
       handleMovAvg = iMA(_Symbol, MATimeframe, MA_period, 0, MA_Mode, MA_AppPrice);
   }
   
   if (IsRSIFilter() || IsUpcomingNews() || IsMaFilter()) {
       CloseAllPositions();
       Tradingenabled = false;
   
       if (TradingenabledComm != "printed") {
           Print(TradingenabledComm);
           TradingenabledComm = "printed";
       }
       return;
   }
   
   Tradingenabled = true;
   
   if (TradingenabledComm != "") {
       Print("Trading is enabled again");
       TradingenabledComm = "";
   }

   MqlDateTime time;
   TimeToStruct(TimeCurrent(), time); // Convierte el tiempo actual a estructura MqlDateTime

   int Hournow = time.hour; // Hora actual

   // Controla el horario de operación considerando el cruce de medianoche
   bool isWithinOperatingHours = false;
   if (SHInput < EHInput) {
        // Caso normal, sin cruce de medianoche
        isWithinOperatingHours = (Hournow >= SHInput && Hournow < EHInput);
    } else if (SHInput > EHInput) {
        // Caso con cruce de medianoche
        isWithinOperatingHours = (Hournow >= SHInput || Hournow < EHInput);
    } else {
        // Caso especial donde SHInput == EHInput, significando 24 horas de operación
        isWithinOperatingHours = true;
    }

    // Si el tiempo actual está fuera del rango operativo
    if (!isWithinOperatingHours) {
        if (InpCloseAtEnd) {
            CloseAllPositions(); // Cierra todas las posiciones si está habilitado
        }
        return; // Sale de la función sin hacer más nada
    }

    int BuyTotal = 0;
    int SellTotal = 0;

    // Verifica las posiciones abiertas
    for (int i = PositionsTotal() - 1; i >= 0; i--)
    {
        pos.SelectByIndex(i);
        if (pos.PositionType() == POSITION_TYPE_BUY && pos.Symbol() == _Symbol && pos.Magic() == InpMagicNumber) BuyTotal++;
        if (pos.PositionType() == POSITION_TYPE_SELL && pos.Symbol() == _Symbol && pos.Magic() == InpMagicNumber) SellTotal++;
    }

    // Verifica las órdenes pendientes
    for (int i = OrdersTotal() - 1; i >= 0; i--)
    {
        ord.SelectByIndex(i);
        if (ord.OrderType() == ORDER_TYPE_BUY_STOP && ord.Symbol() == _Symbol && ord.Magic() == InpMagicNumber) BuyTotal++;
        if (ord.OrderType() == ORDER_TYPE_SELL_STOP && ord.Symbol() == _Symbol && ord.Magic() == InpMagicNumber) SellTotal++;
    }
    // Verifica las órdenes pendientes
    for (int i = OrdersTotal() - 1; i >= 0; i--)
    {
        ord.SelectByIndex(i);
        if (ord.OrderType() == ORDER_TYPE_BUY_LIMIT && ord.Symbol() == _Symbol && ord.Magic() == InpMagicNumber) BuyTotal++;
        if (ord.OrderType() == ORDER_TYPE_SELL_LIMIT && ord.Symbol() == _Symbol && ord.Magic() == InpMagicNumber) SellTotal++;
    }

      // Según el modo del bot, decide las órdenes pendientes
      double high = findHigh(); // Encuentra el valor alto para las órdenes
      double low = findLow();   // Encuentra el valor bajo para las órdenes
      
      if (InpBotMode == MODE_NORMAL) {
          // Modo normal
          if (BuyTotal <= 0 && high > 0) {
              SendBuyOrder(high); // Orden de compra en el máximo
              DrawHighLine(high);  // Dibuja la línea para el valor alto
              if (InpBreakEven) { 
                  DrawTPLines(high, ORDER_TYPE_BUY); // Dibuja las líneas de TP para la orden de compra
              }
          }
          if (SellTotal <= 0 && low > 0) {
              SendSellOrder(low); // Orden de venta en el mínimo
              DrawLowLine(low);  // Dibuja la línea para el valor alto
              if (InpBreakEven) {
                  DrawTPLines(low, ORDER_TYPE_SELL); // Dibuja las líneas de TP para la orden de venta
              }
          }
      } else if (InpBotMode == MODE_INVERTED) {
          // Modo invertido
          if (SellTotal <= 0 && high > 0) {
              SellOrderReverse(high); // Orden de venta en el máximo
              DrawHighLine(high);  // Dibuja la línea para el valor alto
              if (InpBreakEven) {
                  DrawTPLines(high, ORDER_TYPE_SELL); // Dibuja las líneas de TP para la orden de venta invertida
              }
          }
          if (BuyTotal <= 0 && low > 0) {
              BuyOrderReverse(low); // Orden de compra en el mínimo
              DrawLowLine(low);  // Dibuja la línea para el valor alto
              if (InpBreakEven) {
                  DrawTPLines(low, ORDER_TYPE_BUY); // Dibuja las líneas de TP para la orden de compra invertida
              }
          }
      }
}
bool CheckInputs(){
   // Verificar si ambos parámetros están activados
    if (EnableTrailingStop && InpBreakEven)
    {
        Print("Error: No se pueden activar ambos parámetros break even y break even por niveles al mismo tiempo.");
        return false;
    }
    
    if (InpTrailingStop <= Break_after_pts) {
      Print("Error: InpTrailingStop no puede ser menor o igual a Break_after_pts.");
      // Detener la ejecución del código
      return false;
   }
   
  
   
   return true;
}
//+------------------------------------------------------------------+
//| Funciones auxiliares                                              |
//+------------------------------------------------------------------+

// Encuentra el máximo valor alto de las últimas barras
double findHigh()
{
   double highestHigh = 0;
   for (int i = 0; i < InpBarsToAnalyze; i++)
   {
      double high = iHigh(_Symbol, PERIOD_CURRENT, i);
      if (i > BarsN && iHighest(_Symbol, PERIOD_CURRENT, MODE_HIGH, BarsN * 2 + 1, i - BarsN) == i)
      {
         if (high > highestHigh)
         {
            return high;
         }
      }
      highestHigh = MathMax(high, highestHigh);
   }
   return -1;
}

// Encuentra el valor más bajo de las últimas barras
double findLow()
{
   double lowestLow = DBL_MAX;
   for (int i = 0; i < InpBarsToAnalyze; i++)
   {
      double low = iLow(_Symbol, PERIOD_CURRENT, i);
      if (i > BarsN && iLowest(_Symbol,PERIOD_CURRENT, MODE_LOW, BarsN * 2 + 1, i - BarsN) == i)
      {
         if (low < lowestLow)
         {
            return low;
         }
      }
      lowestLow = MathMin(low, lowestLow);
   }
   return -1;
}

// Verifica si hay una nueva barra
bool IsNewBar()
{
   static datetime previusTime = 0;
   datetime curretTime = iTime(_Symbol,PERIOD_CURRENT, 0);
   if (previusTime != curretTime)
   {
      previusTime = curretTime;
      return true;
   }
   return false;
}

void SendBuyOrder(double entry)
{
    // Definir un identificador único para las órdenes de compra
    string buyOrderComment = "BuyOrderFromSendBuyOrder";

    long spread = SymbolInfoInteger(_Symbol, SYMBOL_SPREAD);
    if (spread > (long)MaxSpread) return; // Verificar si el spread es mayor que el límite permitido

    double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
    // Si el modo es aumentar, mover la orden por encima del máximo
    if (InpMode == MODE_INCREASE) {
        entry = entry + InpPoints * _Point;
    }
    // Si el modo es disminuir, mover la orden por debajo del máximo
    else if (InpMode == MODE_DECREASE) {
        entry = entry - InpPoints * _Point;
    }

    if (ask > entry - OrderDiskPoints * _Point) return;

    double tp = entry + InpTp * _Point; // Puntos de Take Profit
    double sl = entry - InpSl * _Point; // Puntos de Stop Loss

    double lots = 0; // Inicializar el tamaño del lote
    if (InpPercent > 0) 
    {
        if (!CalculateLots(entry - sl, lots)) // Calcular el tamaño del lote basado en el riesgo
        {
            Print("Error en el cálculo del lote.");
            return;
        }
    }

    datetime expiration = iTime(_Symbol, PERIOD_CURRENT, 0) + ExpirationsBars * PeriodSeconds(PERIOD_CURRENT);
    trade.BuyStop(lots, entry, _Symbol, sl, tp, ORDER_TIME_SPECIFIED, expiration, buyOrderComment); // Envía la orden de compra con comentario
}


void BuyOrderReverse(double entry)
{
    // Definir un identificador único para las órdenes de compra
    string buyOrderComment = "BuyOrderFromBuyOrderReverse";

    long spread = SymbolInfoInteger(_Symbol, SYMBOL_SPREAD);
    if (spread > (long)MaxSpread) return; // Verificar si el spread es mayor que el límite permitido

    double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
    // Si el modo es aumentar, mover la orden por encima del máximo
    if (InpMode == MODE_INCREASE) {
        entry = entry - InpPoints * _Point;
    }
    // Si el modo es disminuir, mover la orden por debajo del máximo
    else if (InpMode == MODE_DECREASE) {
        entry = entry + InpPoints * _Point;
    }
    if (entry > ask) return; // La entrada para Buy Limit debe estar por debajo del precio actual

    double tp = entry + InpTp * _Point; // Puntos de Take Profit
    double sl = entry - InpSl * _Point; // Puntos de Stop Loss

    double lots = 0; // Inicializar el tamaño del lote
    if (InpPercent > 0) 
    {
        if (!CalculateLots(entry - sl, lots)) // Calcular el tamaño del lote basado en el riesgo
        {
            Print("Error en el cálculo del lote.");
            return;
        }
    }

    datetime expiration = iTime(_Symbol, PERIOD_CURRENT, 0) + ExpirationsBars * PeriodSeconds(PERIOD_CURRENT);
    trade.BuyLimit(lots, entry, _Symbol, sl, tp, ORDER_TIME_SPECIFIED, expiration, buyOrderComment); // Envía la orden Buy Limit con comentario
}


// funcion operacion en contra de la compra
void DetectAndPlaceSellOrder()
{
   if (!InpCounterOperation) return; // Salir si el trailing stop está desactivado
    string sellOrderComment = "SellOrderFromFunction"; // Identificador único para las órdenes de esta función

    // Itera sobre las posiciones abiertas para verificar si hay nuevas compras activadas
    for (int i = PositionsTotal() - 1; i >= 0; i--)
    {
        if (pos.SelectByIndex(i)) // Selecciona la posición por índice
        {
            // Verifica que sea una posición de compra con el Magic Number correcto y con los comentarios específicos de las órdenes de compra
            if (pos.Symbol() == _Symbol && pos.Magic() == InpMagicNumber && pos.PositionType() == POSITION_TYPE_BUY)
            {
                string orderComment = pos.Comment();
                if (orderComment == "BuyOrderFromSendBuyOrder" || orderComment == "BuyOrderFromBuyOrderReverse") // Verificar los comentarios
                {
                    double buyPrice = pos.PriceOpen(); // Obtén el precio de apertura de la compra
                    double sellEntry = buyPrice - InpSellOrderDistance * _Point; // Calcula el nivel para la orden de venta
                    double tp = sellEntry - InpTp * _Point; // Take Profit para la venta
                    double sl = sellEntry + InpSl * _Point; // Stop Loss para la venta

                    // Asegúrate de que no exista ya una orden de venta en ese nivel con el comentario específico
                    bool orderExists = false;
                    for (int j = OrdersTotal() - 1; j >= 0; j--)
                    {
                        if (ord.SelectByIndex(j))
                        {
                            if (ord.OrderType() == ORDER_TYPE_SELL_STOP && ord.PriceOpen() == sellEntry && ord.Comment() == sellOrderComment)
                            {
                                orderExists = true;
                                break;
                            }
                        }
                    }

                    // Si no existe una orden de venta en ese nivel
                    if (!orderExists && sellOrderCounter == 0)
                    {
                        double lots = pos.Volume(); // Utiliza el mismo volumen que la compra

                        // Enviar la orden de venta sin expiración
                        if (!trade.SellStop(lots, sellEntry, _Symbol, sl, tp, ORDER_TIME_GTC, 0, sellOrderComment)) // Cambié la expiración a 'GTC' (Good Till Canceled)
                        {
                            Print("Error al enviar la orden de venta: ", trade.ResultRetcodeDescription());
                        }
                        else
                        {
                            Print("Orden de venta enviada a ", sellEntry, " con SL: ", sl, " y TP: ", tp);
                            sellOrderCounter++; // Aumenta el contador de órdenes de venta
                        }
                    }
                }
            }
        }
    }

    // Verifica si la posición de compra se ha cerrado para eliminar la orden de venta específica
    bool buyPositionClosed = true;
    for (int i = PositionsTotal() - 1; i >= 0; i--)
    {
        if (pos.SelectByIndex(i) && pos.PositionType() == POSITION_TYPE_BUY && pos.Symbol() == _Symbol && pos.Magic() == InpMagicNumber)
        {
            buyPositionClosed = false; // La posición de compra sigue abierta
            break;
        }
    }

    // Si la posición de compra se ha cerrado, elimina solo la orden de venta generada por esta función
    if (buyPositionClosed)
    {
        sellOrderCounter = 0; // Resetea el contador cuando la posición de compra se cierra

        for (int i = OrdersTotal() - 1; i >= 0; i--)
        {
            if (ord.SelectByIndex(i))
            {
                // Elimina únicamente las órdenes de venta generadas por esta función (identificadas por el comentario)
                if (ord.OrderType() == ORDER_TYPE_SELL_STOP && ord.Comment() == sellOrderComment && ord.Magic() == InpMagicNumber)
                {
                    if (trade.OrderDelete(ord.Ticket())) // Elimina la orden pendiente
                    {
                        Print("Orden de venta eliminada por cierre de la posición de compra.");
                    }
                    else
                    {
                        Print("Error al eliminar la orden de venta: ", trade.ResultRetcodeDescription());
                    }
                }
            }
        }
    }
}



// Enviar orden Stop de venta
void SendSellOrder(double entry)
{
    string sellOrderComment = "SellOrderFromSendSellOrder"; // Comentario único para identificar la orden

    long spread = SymbolInfoInteger(_Symbol, SYMBOL_SPREAD);
    if (spread > (long)MaxSpread) return; // Verificar si el spread es mayor que el límite permitido

    double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
    // Si el modo es aumentar, mover la orden por encima del máximo
    if (InpMode == MODE_INCREASE) {
        entry = entry - InpPoints * _Point;
    }
    // Si el modo es disminuir, mover la orden por debajo del máximo
    else if (InpMode == MODE_DECREASE) {
        entry = entry + InpPoints * _Point;
    }

    if (bid < entry - OrderDiskPoints * _Point) return;

    double tp = entry - InpTp * _Point; // Puntos de Take Profit
    double sl = entry + InpSl * _Point; // Puntos de Stop Loss

    double lots = 0; // Inicializar el tamaño del lote
    if (InpPercent > 0) 
    {
        if (!CalculateLots(sl - entry, lots)) // Calcular el tamaño del lote basado en el riesgo
        {
            Print("Error en el cálculo del lote.");
            return;
        }
    }

    datetime expiration = iTime(_Symbol, PERIOD_CURRENT, 0) + ExpirationsBars * PeriodSeconds(PERIOD_CURRENT);
    trade.SellStop(lots, entry, _Symbol, sl, tp, ORDER_TIME_SPECIFIED, expiration, sellOrderComment); // Envía la orden de venta con el comentario único
}

// Enviar orden limitada de venta (Sell Limit)
void SellOrderReverse(double entry)
{
    string sellOrderComment = "SellOrderFromSellOrderReverse"; // Comentario único para identificar la orden

    long spread = SymbolInfoInteger(_Symbol, SYMBOL_SPREAD);
    if (spread > (long)MaxSpread) return; // Verificar si el spread es mayor que el límite permitido

    double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
    // Si el modo es aumentar, mover la orden por encima del máximo
    if (InpMode == MODE_INCREASE) {
        entry = entry + InpPoints * _Point;
    }
    // Si el modo es disminuir, mover la orden por debajo del máximo
    else if (InpMode == MODE_DECREASE) {
        entry = entry - InpPoints * _Point;
    }
    
    if (entry < bid) return; // La entrada para Sell Limit debe estar por encima del precio actual

    double tp = entry - InpTp * _Point; // Puntos de Take Profit
    double sl = entry + InpSl * _Point; // Puntos de Stop Loss

    double lots = 0; // Inicializar el tamaño del lote
    if (InpPercent > 0) 
    {
        if (!CalculateLots(sl - entry, lots)) // Calcular el tamaño del lote basado en el riesgo
        {
            Print("Error en el cálculo del lote.");
            return;
        }
    }

    datetime expiration = iTime(_Symbol, PERIOD_CURRENT, 0) + ExpirationsBars * PeriodSeconds(PERIOD_CURRENT);
    trade.SellLimit(lots, entry, _Symbol, sl, tp, ORDER_TIME_SPECIFIED, expiration, sellOrderComment); // Envía la orden Sell Limit con el comentario único
}

//funcion en contra de la venta 
void DetectAndPlaceBuyOrder()
{
    if (!InpCounterOperation) return; // Salir si la operación está desactivada
    string buyOrderComment = "BuyOrderFromFunction"; // Comentario único para las órdenes de compra

    // Itera sobre las posiciones abiertas para verificar si hay nuevas ventas activadas
    for (int i = PositionsTotal() - 1; i >= 0; i--)
    {
        if (pos.SelectByIndex(i)) // Selecciona la posición por índice
        {
            // Verifica que sea una posición de venta con el Magic Number correcto
            if (pos.Symbol() == _Symbol && pos.Magic() == InpMagicNumber && pos.PositionType() == POSITION_TYPE_SELL)
            {
                string orderComment = pos.Comment();
                if (orderComment == "SellOrderFromSendSellOrder" || orderComment == "SellOrderFromSellOrderReverse") // Verifica los comentarios
                {
                    double sellPrice = pos.PriceOpen(); // Obtén el precio de apertura de la venta
                    double buyEntry = sellPrice + InpBuyOrderDistance * _Point; // Calcula el nivel para la orden de compra
                    double tp = buyEntry + InpTp * _Point; // Take Profit para la compra
                    double sl = buyEntry - InpSl * _Point; // Stop Loss para la compra

                    // Asegúrate de que no exista ya una orden de compra en ese nivel con el comentario específico
                    bool orderExists = false;
                    for (int j = OrdersTotal() - 1; j >= 0; j--)
                    {
                        if (ord.SelectByIndex(j))
                        {
                            if (ord.OrderType() == ORDER_TYPE_BUY_STOP && ord.PriceOpen() == buyEntry && ord.Comment() == buyOrderComment)
                            {
                                orderExists = true;
                                break;
                            }
                        }
                    }

                    // Si no existe una orden de compra en ese nivel
                    if (!orderExists && buyOrderCounter == 0)
                    {
                        double lots = pos.Volume(); // Utiliza el mismo volumen que la venta

                        // Enviar la orden de compra sin expiración
                        if (!trade.BuyStop(lots, buyEntry, _Symbol, sl, tp, ORDER_TIME_GTC, 0, buyOrderComment)) // Cambié la expiración a 'GTC' (Good Till Canceled)
                        {
                            Print("Error al enviar la orden de compra: ", trade.ResultRetcodeDescription());
                        }
                        else
                        {
                            Print("Orden de compra enviada a ", buyEntry, " con SL: ", sl, " y TP: ", tp);
                            buyOrderCounter++; // Aumenta el contador de órdenes de compra
                        }
                    }
                }
            }
        }
    }

    // Verifica si la posición de venta se ha cerrado para eliminar la orden de compra específica
    bool sellPositionClosed = true;
    for (int i = PositionsTotal() - 1; i >= 0; i--)
    {
        if (pos.SelectByIndex(i) && pos.PositionType() == POSITION_TYPE_SELL && pos.Symbol() == _Symbol && pos.Magic() == InpMagicNumber)
        {
            sellPositionClosed = false; // La posición de venta sigue abierta
            break;
        }
    }

    // Si la posición de venta se ha cerrado, elimina solo la orden de compra generada por esta función
    if (sellPositionClosed)
    {
        buyOrderCounter = 0; // Resetea el contador cuando la posición de venta se cierra

        for (int i = OrdersTotal() - 1; i >= 0; i--)
        {
            if (ord.SelectByIndex(i))
            {
                // Elimina únicamente las órdenes de compra generadas por esta función (identificadas por el comentario)
                if (ord.OrderType() == ORDER_TYPE_BUY_STOP && ord.Comment() == buyOrderComment && ord.Magic() == InpMagicNumber)
                {
                    if (trade.OrderDelete(ord.Ticket())) // Elimina la orden pendiente
                    {
                        Print("Orden de compra eliminada por cierre de la posición de venta.");
                    }
                    else
                    {
                        Print("Error al eliminar la orden de compra: ", trade.ResultRetcodeDescription());
                    }
                }
            }
        }
    }
}


void CheckActivatedOrders()
{
    if (!EnableOrderCleanup) return; // Si la funcionalidad está desactivada, salimos de la función

    // Variables para rastrear las órdenes pendientes
    ulong buyTicket = 0;
    ulong sellTicket = 0;

    // Identificar las órdenes pendientes de compra y venta de SendBuyOrder y SendSellOrder
    for (int i = OrdersTotal() - 1; i >= 0; i--)
    {
        if (!ord.SelectByIndex(i)) continue;

        if (ord.Symbol() == _Symbol && ord.Magic() == InpMagicNumber)
        {
            // Si la orden es de compra o venta generada por SendBuyOrder o SendSellOrder
            if ((ord.OrderType() == ORDER_TYPE_BUY_STOP || ord.OrderType() == ORDER_TYPE_BUY_LIMIT) && ord.Comment() != "BuyOrderFromFunction")
                buyTicket = ord.Ticket();
            else if ((ord.OrderType() == ORDER_TYPE_SELL_STOP || ord.OrderType() == ORDER_TYPE_SELL_LIMIT) && ord.Comment() != "SellOrderFromFunction")
                sellTicket = ord.Ticket();
        }
    }

    // Verificar posiciones abiertas y eliminar la orden contraria si corresponde
    for (int i = PositionsTotal() - 1; i >= 0; i--)
    {
        if (!pos.SelectByIndex(i)) continue;

        if (pos.Symbol() == _Symbol && pos.Magic() == InpMagicNumber)
        {
            if (pos.PositionType() == POSITION_TYPE_BUY && sellTicket > 0)
            {
                trade.OrderDelete(sellTicket); // Elimina la orden de venta
                Print("Se activó una orden de compra. Orden de venta eliminada.");
            }
            else if (pos.PositionType() == POSITION_TYPE_SELL && buyTicket > 0)
            {
                trade.OrderDelete(buyTicket); // Elimina la orden de compra
                Print("Se activó una orden de venta. Orden de compra eliminada.");
            }
        }
    }
}


bool CalculateLots(double slDistance, double &lots)
{
   // Usar el balance ingresado en el parámetro InpBalance solo si UseCustomBalance está activado
   double balance = (UseCustomBalance && InpBalance > 0) ? InpBalance : AccountInfoDouble(ACCOUNT_EQUITY);
   lots = 0.0;

   // Variables comunes
   double tickSize    = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
   double tickValue   = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
   double VolumenStep = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   
   // Calcular el dinero a arriesgar según el modo seleccionado
   double riskMoney = 0.0;

   if (InpLotMode == LOT_MODE_FIXED)
   {
      // Por lotaje fijo
      lots = InpPercent;
   }
   else if (InpLotMode == LOT_MODE_MONEY)
   {
      // Por dinero
      riskMoney = InpPercent;
      double moneyVolumeStp = (slDistance / tickSize) * tickValue * VolumenStep;
      lots = MathFloor(riskMoney / moneyVolumeStp) * VolumenStep;
   }
   else if (InpLotMode == LOT_MODE_PCT_ACCOUNT)
   {
      // Cálculo basado en el balance ingresado (o balance real si UseCustomBalance está desactivado)
      riskMoney = balance * InpPercent * 0.01; // Usar el balance calculado correctamente
      double moneyVolumeStp = (slDistance / tickSize) * tickValue * VolumenStep;
      lots = MathFloor(riskMoney / moneyVolumeStp) * VolumenStep;
   }

   // Ajustar el incremento según el modo de lotaje
   if (EnableLotIncrease && lastTradeLost)
   {
      if (InpLotMode == LOT_MODE_FIXED)
      {
         // Incremento por lotaje
         lots = lastLotSize + LotIncrement;  // Incremento de lotaje
      }
      else if (InpLotMode == LOT_MODE_MONEY)
      {
         // Por dinero
         riskMoney = InpPercent;
      
         // Incremento por pérdida activado
         double incrementMoney = LotIncrement; // Incremento definido directamente
         riskMoney += incrementMoney;         // Sumar al riesgo total
         
         // Calcular lotes basado en el riesgo ajustado
         double moneyVolumeStp = (slDistance / tickSize) * tickValue * VolumenStep;
         lots = MathFloor(riskMoney / moneyVolumeStp) * VolumenStep;
      }
      else if (InpLotMode == LOT_MODE_PCT_ACCOUNT)
      {
         // Incremento por porcentaje
         double incrementPct = AccountInfoDouble(ACCOUNT_EQUITY) * LotIncrement * 0.01;
         riskMoney += incrementPct;
         lots = MathFloor(riskMoney / (slDistance / tickSize * tickValue * VolumenStep)) * VolumenStep;
      }
   }
   else
   {
      // Si la última operación no fue una pérdida, se restablece el lote base
      if (!lastTradeLost)
      {
         if (InpLotMode == LOT_MODE_FIXED)
         {
            lots = InpPercent;  // Restablecer al valor base de lotaje
         }
         else if (InpLotMode == LOT_MODE_MONEY)
         {
            riskMoney = InpPercent;
            double moneyVolumeStp = (slDistance / tickSize) * tickValue * VolumenStep;
            lots = MathFloor(riskMoney / moneyVolumeStp) * VolumenStep;  // Restablecer al valor base en dinero
         }
         else if (InpLotMode == LOT_MODE_PCT_ACCOUNT)
         {
            riskMoney = balance * InpPercent * 0.01; // Usar el balance calculado correctamente
            double moneyVolumeStp = (slDistance / tickSize) * tickValue * VolumenStep;
            lots = MathFloor(riskMoney / moneyVolumeStp) * VolumenStep;  // Restablecer al valor base en porcentaje
         }
      }
   }

   // Verifica lotes calculados
   if (!CheckLots(lots)) return false;

   lastLotSize = lots; // Actualiza el tamaño del lote para futuras referencias
   return true;
}

// verifica los lotes maximo y minimos
bool CheckLots(double &lots){
   
   double min = SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MIN);
   double max = SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MAX);
   double step = SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_STEP);
   
   if(lots<min){
      Print("el tamaño del lote se establecera en el volumen minimo permitido");
      lots = min;
      return true;
   }
   if(lots>max){
      Print("tamaño del lote mayor que el volumen permitido. lote:",lots,"max:",max);
      return false;
   }
   
   lots = (int)MathFloor(lots/step) * step;
   
   return true;
}

// Función para registrar el resultado de la última operación
void UpdateLastTradeStatus()
{
   lastTradeLost = false; // Reinicia el estado de pérdida

   // Recorre las posiciones abiertas y verifica el resultado de la última
   for (int i = PositionsTotal() - 1; i >= 0; i--)
   {
      if (pos.SelectByIndex(i) && pos.Symbol() == _Symbol && pos.Magic() == InpMagicNumber)
      {
         if (pos.Profit() < 0) // Si la operación tuvo una pérdida
         {
            lastTradeLost = true;
         }
         break; // Sale después de procesar la última operación
      }
   }
}
// Cerrar todas las posiciones abiertas
void CloseAllPositions()
{
    for (int i = PositionsTotal() - 1; i >= 0; i--)
    {
        if (pos.SelectByIndex(i) && pos.Symbol() == _Symbol && pos.Magic() == InpMagicNumber)
        {
            ulong ticket = pos.Ticket();
            if (pos.PositionType() == POSITION_TYPE_BUY)
            {
                trade.PositionClose(ticket); // Cierra posición de compra
            }
            else if (pos.PositionType() == POSITION_TYPE_SELL)
            {
                trade.PositionClose(ticket); // Cierra posición de venta
            }
        }
    }
}

void ManageBreakEvenAndTrailingStop()
{
    if (!EnableTrailingStop) return; // Salir si el trailing stop está desactivado

    // Verifica las posiciones abiertas
    for (int i = PositionsTotal() - 1; i >= 0; i--)
    {
        pos.SelectByIndex(i);
        if (pos.Symbol() == _Symbol && pos.Magic() == InpMagicNumber)
        {
            ulong ticket = pos.Ticket();  // Obtener el ticket de la posición
            double sl = pos.StopLoss();   // Obtener el SL actual
            double open_price = pos.PriceOpen();  // Precio de apertura de la posición

            // Acceso a los precios de Bid y Ask
            double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID); // Obtener el precio de compra (Bid)
            double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK); // Obtener el precio de venta (Ask)

            // Para posiciones de compra (BUY)
            if (pos.PositionType() == POSITION_TYPE_BUY)
            {
                // Verificar si se alcanzó el Break Even
                if (bid - open_price >= Break_after_pts * _Point)  // Activación del Break Even
                {
                    double break_even_sl = open_price + Break_at_pts * _Point;
                    break_even_sl = NormalizeDouble(break_even_sl, _Digits);

                    if (sl < break_even_sl)  // Aplicar Break Even si no está activado
                    {
                        if (trade.PositionModify(ticket, break_even_sl, pos.TakeProfit()))
                        {
                            Print("Break Even aplicado para compra. Nuevo SL: ", break_even_sl);
                        }
                    }
                }

                // Activar Trailing Stop solo si Break Even ya fue aplicado
                if (bid - open_price >= Break_after_pts * _Point)  // Confirmar que Break Even ya fue activado
                {
                    if (bid - open_price >= InpTrailingStop * _Point)  // Verificar si el Trailing Stop debe activarse
                    {
                        double new_sl = bid - (TslPoints * _Point);
                        new_sl = NormalizeDouble(new_sl, _Digits);

                        // Solo mover SL si el nuevo SL está a la distancia definida
                        if ((new_sl - sl) >= InpFollowPoints * _Point)  // Mover SL al avanzar InpFollowPoints
                        {
                            if (trade.PositionModify(ticket, new_sl, pos.TakeProfit()))
                            {
                                Print("Trailing Stop actualizado para compra. Nuevo SL: ", new_sl);
                            }
                        }
                    }
                }
            }

            // Para posiciones de venta (SELL)
            if (pos.PositionType() == POSITION_TYPE_SELL)
            {
                // Verificar si se alcanzó el Break Even
                if (open_price - ask >= Break_after_pts * _Point)  // Activación del Break Even
                {
                    double break_even_sl = open_price - Break_at_pts * _Point;
                    break_even_sl = NormalizeDouble(break_even_sl, _Digits);

                    if (sl > break_even_sl)  // Aplicar Break Even si no está activado
                    {
                        if (trade.PositionModify(ticket, break_even_sl, pos.TakeProfit()))
                        {
                            Print("Break Even aplicado para venta. Nuevo SL: ", break_even_sl);
                        }
                    }
                }

                // Activar Trailing Stop solo si Break Even ya fue aplicado
                if (open_price - ask >= Break_after_pts * _Point)  // Confirmar que Break Even ya fue activado
                {
                    if (open_price - ask >= InpTrailingStop * _Point)  // Verificar si el Trailing Stop debe activarse
                    {
                        double new_sl = ask + (TslPoints * _Point);
                        new_sl = NormalizeDouble(new_sl, _Digits);

                        // Solo mover SL si el nuevo SL está a la distancia definida
                        if ((sl - new_sl) >= InpFollowPoints * _Point)  // Mover SL al retroceder InpFollowPoints
                        {
                            if (trade.PositionModify(ticket, new_sl, pos.TakeProfit()))
                            {
                                Print("Trailing Stop actualizado para venta. Nuevo SL: ", new_sl);
                            }
                        }
                    }
                }
            }
        }
    }
}


// Función: Actualizar Break Even por niveles
void UpdateBreakEvenLevels() {
   if (!InpBreakEven) return;  // Salir si Break Even no está activado

   for (int i = PositionsTotal() - 1; i >= 0; i--) {
      ulong ticket = PositionGetTicket(i);
      if (ticket <= 0 || !PositionSelectByTicket(ticket)) continue;

      // Validar el número mágico
      long magicnumber;
      PositionGetInteger(POSITION_MAGIC, magicnumber);
      if (magicnumber != InpMagicNumber) continue;

      // Obtener información de la posición
      long positionType = PositionGetInteger(POSITION_TYPE);
      double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
      double currentPrice = (positionType == ORDER_TYPE_BUY) ? SymbolInfoDouble(_Symbol, SYMBOL_BID) : SymbolInfoDouble(_Symbol, SYMBOL_ASK);
      double profitPoints = (positionType == ORDER_TYPE_BUY) ? (currentPrice - openPrice) / _Point : (openPrice - currentPrice) / _Point;
      double sl = PositionGetDouble(POSITION_SL);

      // Nivel 1 de Break Even
      if (profitPoints >= InpBreakEventp1) {
         double breakEvenPrice1 = (positionType == ORDER_TYPE_BUY) ? openPrice + (InpBreakEvenDistance * _Point) : openPrice - (InpBreakEvenDistance * _Point);
         if ((positionType == ORDER_TYPE_BUY && (sl == 0 || sl < breakEvenPrice1)) || (positionType == ORDER_TYPE_SELL && (sl == 0 || sl > breakEvenPrice1))) {
            if (trade.PositionModify(ticket, breakEvenPrice1, PositionGetDouble(POSITION_TP))) {
               Print("Break Even nivel 1 activado en la posición: ", ticket, " al nivel: ", breakEvenPrice1);
            } else {
               Print("Error al mover el SL en el nivel 1: ", GetLastError());
            }
         }
      }

      // Nivel 2 de Break Even
      if (profitPoints >= InpBreakEventp2) {
         double breakEvenPrice2 = (positionType == ORDER_TYPE_BUY) ? openPrice + (InpBreakEventp1 * _Point) + (InpBreakEvenDistance * _Point) : openPrice - (InpBreakEventp1 * _Point) - (InpBreakEvenDistance * _Point);
         if ((positionType == ORDER_TYPE_BUY && sl < breakEvenPrice2) || (positionType == ORDER_TYPE_SELL && sl > breakEvenPrice2)) {
            if (trade.PositionModify(ticket, breakEvenPrice2, PositionGetDouble(POSITION_TP))) {
               Print("Break Even nivel 2 activado en la posición: ", ticket, " al nivel: ", breakEvenPrice2);
            } else {
               Print("Error al mover el SL en el nivel 2: ", GetLastError());
            }
         }
      }

      // Nivel 3 de Break Even: cerrar posición
      if (profitPoints >= InpBreakEventp3) {
         if (trade.PositionClose(ticket)) {
            Print("Posición cerrada en el nivel 3 (TP3) para el ticket: ", ticket);
         } else {
            Print("Error al cerrar la posición en el nivel 3: ", GetLastError());
         }
      }
   }
}

// Función para dibujar las líneas de TP
void DrawTPLines(double openPrice, long positionType) {
    // Si Break Even está desactivado, no dibujar las líneas de TP
    if (!InpBreakEven) return;

    // Inicializar las variables TP1, TP2 y TP3 con valores predeterminados
    double TP1 = 0, TP2 = 0, TP3 = 0;

    // Si la orden es de compra
    if (positionType == ORDER_TYPE_BUY) {
        TP1 = openPrice + InpBreakEventp1 * _Point;
        TP2 = openPrice + InpBreakEventp2 * _Point;
        TP3 = openPrice + InpBreakEventp3 * _Point;

        // Crear las líneas de TP para la compra
        ObjectCreate(0, "TP1_BUY", OBJ_HLINE, 0, TimeCurrent(), TP1);
        ObjectSetInteger(0, "TP1_BUY", OBJPROP_COLOR, InpColorLevels);
        ObjectCreate(0, "TP2_BUY", OBJ_HLINE, 0, TimeCurrent(), TP2);
        ObjectSetInteger(0, "TP2_BUY", OBJPROP_COLOR, InpColorLevels);
        ObjectCreate(0, "TP3_BUY", OBJ_HLINE, 0, TimeCurrent(), TP3);
        ObjectSetInteger(0, "TP3_BUY", OBJPROP_COLOR, InpColorLevels);
    }
    // Si la orden es de venta
    if (positionType == ORDER_TYPE_SELL) {
        TP1 = openPrice - InpBreakEventp1 * _Point;
        TP2 = openPrice - InpBreakEventp2 * _Point;
        TP3 = openPrice - InpBreakEventp3 * _Point;

        // Crear las líneas de TP para la venta
        ObjectCreate(0, "TP1_SELL", OBJ_HLINE, 0, TimeCurrent(), TP1);
        ObjectSetInteger(0, "TP1_SELL", OBJPROP_COLOR, InpColorLevels);
        ObjectCreate(0, "TP2_SELL", OBJ_HLINE, 0, TimeCurrent(), TP2);
        ObjectSetInteger(0, "TP2_SELL", OBJPROP_COLOR, InpColorLevels);
        ObjectCreate(0, "TP3_SELL", OBJ_HLINE, 0, TimeCurrent(), TP3);
        ObjectSetInteger(0, "TP3_SELL", OBJPROP_COLOR, InpColorLevels);
    }
}


bool IsUpcomingNews() {
   if (NewsFilteron == false) return false;

   if (TrDisableNews && TimeCurrent() - LastNewsAvoided < StartTradingMin * PeriodSeconds(PERIOD_M1)) 
      return true;

   TrDisableNews = false;

   // Establecer el separador por defecto
   string sep = ";";

   sep_code = StringGetCharacter(sep, 0);
   int k = StringSplit(KeyNews, sep_code, Newstoavoid);

   MqlCalendarValue values[];
   datetime starttime = TimeCurrent();
   datetime endtime = starttime + PeriodSeconds(PERIOD_D1) * DaysNewsLookup;

   CalendarValueHistory(values, starttime, endtime, NULL, NULL);

   for (int i = 0; i < ArraySize(values); i++) {
      MqlCalendarEvent event;
      CalendarEventById(values[i].event_id, event);
      MqlCalendarCountry country;
      CalendarCountryById(event.country_id, country);
   
      if(StringFind(NewsCurrencies,country.currency)< 0)continue;
      for(int j=0; j<k; j++){
         string currentevent = Newstoavoid [j];
         string currentnews = event.name;
         if(StringFind(currentnews,currentevent)< 0)continue;
         
         Comment("siguiente noticia:", country.currency, ":",event.name, "->", values[i].time);
         if(values[i].time - TimeCurrent() < StopBeforeMin*PeriodSeconds(PERIOD_M1)){
            LastNewsAvoided = values[i].time;
            TrDisableNews = true;
            if(TradingenabledComm=="" || TradingenabledComm!="printed"){
               TradingenabledComm= "trading is disable due to upcoming news: " + event.name;
            }
            return true;
         }
         return false;
      }
   }

   return false;
}


// Función para verificar el filtro RSI
bool IsRSIFilter() {
    if (!RSIFILteron) return false;

    double RSI[];
    if (CopyBuffer(handleRSI, MAIN_LINE, 0, 1, RSI) <= 0) {
        Print("Error al copiar el buffer de RSI: ", GetLastError());
        return false;
    }

    ArraySetAsSeries(RSI, true);
    double RSINow = RSI[0];

    if (RSINow > RSIupperlvl || RSINow < RSIlowerlvl) {
        if (TradingenabledComm == "" || TradingenabledComm != "printed") {
            TradingenabledComm = "Trading is disabled due to RSI filter";
        }
        return true;
    }

    return false;
}

// Función para verificar el filtro de Media Móvil
bool IsMaFilter() {
    if (!MAFilterOn) return false;

    double MoAvg[];
    if (CopyBuffer(handleMovAvg, MAIN_LINE, 0, 1, MoAvg) <= 0) {
        Print("Error al copiar el buffer de Media Móvil: ", GetLastError());
        return false;
    }

    ArraySetAsSeries(MoAvg, true);
    double MAnow = MoAvg[0];
    double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);

    if (ask > MAnow * (1 + PctPricefromMa / 100) || 
        ask < MAnow * (1 - PctPricefromMa / 100)) {
        if (TradingenabledComm == "" || TradingenabledComm != "printed") {
            TradingenabledComm = "Trading is disabled due to moving average filter";
        }
        return true;
    }

    return false;
}
// Función para crear el panel gráfico
void CreatePanel() {
    string panel_name = "PanelGrafico";

    // Si el panel está desactivado, eliminarlo si existe y salir
    if (!EnablePanel) {
        if (ObjectFind(0, panel_name) >= 0) {
            ObjectDelete(0, panel_name);
        }
        return;
    }

    // Eliminar cualquier panel existente
    if (ObjectFind(0, panel_name) >= 0) {
        ObjectDelete(0, panel_name);
    }

    // Crear el panel
    if (!ObjectCreate(0, panel_name, OBJ_RECTANGLE_LABEL, 0, 0, 0)) {
        Print("Error creando el panel: ", GetLastError());
        return;
    }

    // Configurar el panel
    ObjectSetInteger(0, panel_name, OBJPROP_XSIZE, panel_width);
    ObjectSetInteger(0, panel_name, OBJPROP_YSIZE, panel_height);
    ObjectSetInteger(0, panel_name, OBJPROP_XDISTANCE, panel_x);
    ObjectSetInteger(0, panel_name, OBJPROP_YDISTANCE, panel_y);
    ObjectSetInteger(0, panel_name, OBJPROP_BORDER_TYPE, BORDER_FLAT);
    ObjectSetInteger(0, panel_name, OBJPROP_COLOR, clrWhite);
    ObjectSetInteger(0, panel_name, OBJPROP_STYLE, STYLE_SOLID);
    ObjectSetInteger(0, panel_name, OBJPROP_BORDER_COLOR, clrBlack);
    ObjectSetInteger(0, panel_name, OBJPROP_BGCOLOR, panel_color);

    // Crear el objeto de texto para el balance
    string balance_text_name = "BalanceText";
    if (ObjectFind(0, balance_text_name) >= 0) {
        ObjectDelete(0, balance_text_name); // Eliminar si ya existe
    }

    ObjectCreate(0, balance_text_name, OBJ_LABEL, 0, 0, 0);
    ObjectSetInteger(0, balance_text_name, OBJPROP_XSIZE, panel_width - 20);  // Ajuste del ancho del texto al panel
    ObjectSetInteger(0, balance_text_name, OBJPROP_YSIZE, panel_height / 4);   // Ajuste del alto del texto proporcional al panel
    ObjectSetInteger(0, balance_text_name, OBJPROP_XDISTANCE, panel_x + 10);
    ObjectSetInteger(0, balance_text_name, OBJPROP_YDISTANCE, panel_y + 30);
    ObjectSetInteger(0, balance_text_name, OBJPROP_COLOR, panel_text);

    // Actualizar el texto del balance
    UpdateBalanceText();  // Asegurarse de que el texto de balance se actualice
}

// Función para actualizar el texto del balance
void UpdateBalanceText() {
    if (!EnablePanel) return; // No actualizar si el panel está desactivado

    double current_balance = AccountInfoDouble(ACCOUNT_BALANCE);
    double profit_loss = current_balance - initial_balance;

    // Mostrar ganancia o pérdida
    if (profit_loss >= 0) {
        balance_text = "Ganancia acumulada: " + DoubleToString(profit_loss, 2);
    } else {
        balance_text = "Pérdida acumulada: " + DoubleToString(profit_loss, 2);
    }

    // Actualizamos el texto en el panel
    ObjectSetString(0, "BalanceText", OBJPROP_TEXT, balance_text);
}

// Función para dibujar la línea del valor alto con un tamaño ajustado
void DrawHighLine(double high)
{
    string highLineName = "HighLine_" + IntegerToString(TimeCurrent());
    
    // Eliminar cualquier línea anterior
    if (ObjectFind(0, "HighLine") != -1)
        ObjectDelete(0, "HighLine");

    // Definir los puntos de inicio y fin de la línea
    datetime startTime = iTime(_Symbol, PERIOD_CURRENT, InpBarsToAnalyze - 1); // Tiempo de inicio
    datetime endTime = iTime(_Symbol, PERIOD_CURRENT, 0); // Tiempo de fin

    // Crear la línea horizontal (OBJ_HLINE) en el valor del máximo
    ObjectCreate(0, "HighLine", OBJ_TREND, 0, startTime, high, endTime, high);
    
    // Configurar el color y el grosor de la línea
    ObjectSetInteger(0, "HighLine", OBJPROP_COLOR, clrGreen);
    ObjectSetInteger(0, "HighLine", OBJPROP_RAY_RIGHT, 0); // No extender la línea más allá del final
    ObjectSetInteger(0, "HighLine", OBJPROP_WIDTH, 2); // Grosor de la línea
}

// Función para dibujar la línea del valor bajo con un tamaño ajustado
void DrawLowLine(double low)
{
    string lowLineName = "LowLine_" + IntegerToString(TimeCurrent());
    
    // Eliminar cualquier línea anterior
    if (ObjectFind(0, "LowLine") != -1)
        ObjectDelete(0, "LowLine");

    // Definir los puntos de inicio y fin de la línea
    datetime startTime = iTime(_Symbol, PERIOD_CURRENT, InpBarsToAnalyze - 1); // Tiempo de inicio
    datetime endTime = iTime(_Symbol, PERIOD_CURRENT, 0); // Tiempo de fin

    // Crear la línea horizontal (OBJ_HLINE) en el valor del mínimo
    ObjectCreate(0, "LowLine", OBJ_TREND, 0, startTime, low, endTime, low);
    
    // Configurar el color y el grosor de la línea
    ObjectSetInteger(0, "LowLine", OBJPROP_COLOR, clrRed);
    ObjectSetInteger(0, "LowLine", OBJPROP_RAY_RIGHT, 0); // No extender la línea más allá del final
    ObjectSetInteger(0, "LowLine", OBJPROP_WIDTH, 2); // Grosor de la línea
}

// Función para dibujar las líneas verticales
void DrawVerticalLines()
{
    // Obtiene la hora actual
    datetime currentTime = TimeCurrent();

    // Calcula la hora de inicio y fin en formato datetime
    datetime startTime = StringToTime(TimeToString(currentTime, TIME_DATE) + " " + IntegerToString(SHInput) + ":00");
    datetime endTime = StringToTime(TimeToString(currentTime, TIME_DATE) + " " + IntegerToString(EHInput) + ":00");

    // Eliminar cualquier línea anterior
    if (ObjectFind(0, "StartLine") != -1)
        ObjectDelete(0, "StartLine");
    if (ObjectFind(0, "EndLine") != -1)
        ObjectDelete(0, "EndLine");

    // Crea la línea vertical para la hora de inicio
    if (startTime > 0)
    {
        ObjectCreate(0, "StartLine", OBJ_VLINE, 0, startTime, 0);
        ObjectSetInteger(0, "StartLine", OBJPROP_COLOR, InpHourStar); // Color verde
        ObjectSetInteger(0, "StartLine", OBJPROP_RAY_RIGHT, false); // No extender la línea
    }

    // Crea la línea vertical para la hora de fin
    if (endTime > 0)
    {
        ObjectCreate(0, "EndLine", OBJ_VLINE, 0, endTime, 0);
        ObjectSetInteger(0, "EndLine", OBJPROP_COLOR, InpEndTime); // Color rojo
        ObjectSetInteger(0, "EndLine", OBJPROP_RAY_RIGHT, false); // No extender la línea
    }
}
