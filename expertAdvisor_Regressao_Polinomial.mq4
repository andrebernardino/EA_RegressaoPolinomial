// 
/* customização
Publicado em 14 de abr de 2016
Hoy veremos en detalle cómo se usa el comando iCustom para convocar un dato de un indicador 
personalizado en otro programa como un Expert Adviser, primero creo un indicador customizado 
simple para luego usarlo en un Expert que compre o venda dependiendo del cierre vs un promedio móvil especial 
(nuestro indicador customizado).
Perdón por los errores de cambio de captura.
Lea las advertencias de riesgo en http://ien4x.com y http://forexhispana.com
*/
// 

#property copyright "© 2008 http://ien4x.com/" 
#property link      "https://www.youtube.com/watch?v=N63YzlX33lk" 

#property strict 


extern double Lots=0.1; 


extern int Regr_Degree=3; 
extern double Regr_Kstd=1.0; 
extern int Regr_Bars=250; 
extern int Regr_Shift=0; 

input int MagicNum = 123123; 
string ind_name="..\\Indicators\\Regressão polinomial e linear\\indicador.ex4"; 

//+------------------------------------------------------------------+ 
//|                                                                  | 
//+------------------------------------------------------------------+ 
int  OnInit() 
  { 
  return(INIT_SUCCEEDED);
  } 
//+------------------------------------------------------------------+ 
//|                                                                  | 
//+------------------------------------------------------------------+ 
void deinit() 
  { 
  } 
//+------------------------------------------------------------------+ 
//|                                                                  | 
//+------------------------------------------------------------------+ 
void OnTick()
{
   //Buscar se ha operações abertas, se sím vamos procura fecha-las, senão vamos procurar abrir
   int ticketAOperar = getTicketAOperar();
   if(ticketAOperar == -1)
   {
      //se não há trades, buscar um
      //Comment("Valor do Indicador: -> ", valorDoIndicadorPersonalizado());
      if(existeCondicoesDeAbrirCompra() == true)
      {
         bool r = OrderSend(NULL,0,Lots, Ask, 20, 0, 0, "Expert Advisor Abre COMPRA", MagicNum, 0,clrAliceBlue);
      }
      if(existeCondicoesDeAbrirVenda() == true)
      {
        bool r = OrderSend(NULL,1,Lots, Bid, 20, 0, 0, "Expert Advisor Abre VENDA", MagicNum, 0, clrBlueViolet);
      }
   }
   //Já tem um trade no ar, então monitorar a saída deste trade
   if(ticketAOperar > -1)
   {
      if(OrderSelect(ticketAOperar, SELECT_BY_TICKET, MODE_TRADES))
      {
         Comment("Tipo de ordem: ", OrderType());
         //se o ticket é uma ordem de compra, então verifica se tem condições de fechar esta ordem
         if(OrderType() == 0 && existeCondicoesDeFecharCompra() == true)
         {
            bool r = OrderClose(ticketAOperar, OrderLots(), OrderClosePrice(), 20, clrGreen);
         }
         //se o ticket é uma ordem de venda, então verifica se tem condições de fechar esta ordem de venda
         if(OrderType() == 1 && existeCondicoesDeFecharVenda() == true)
         {
           bool r = OrderClose(ticketAOperar, OrderLots(), OrderClosePrice(), 20, clrBlue);
         }
      }
   }
}

int getTicketAOperar()
{  
   for(int op = 0; op < OrdersTotal(); op++)
   {
      bool r = OrderSelect(op, SELECT_BY_POS, MODE_TRADES);
      if(OrderMagicNumber() == MagicNum && OrderSymbol() == Symbol())
      {
         return OrderTicket();
      }
      
   }
   return (-1);//não encontrou nada
}

bool existeCondicoesDeAbrirCompra()
{
   bool temCondicoes =  (Low[0] < valorIndicadorLinhaDoMeio(0));
   string condicoes = (temCondicoes == true)?"sim":"não";
   Comment(StringFormat("Existe condições de ABRIR COMPRA: %s %s %s ", DoubleToString(Low[0],4), DoubleToString(valorIndicadorLinhaDeBaixo(0),4), condicoes));
   return temCondicoes;
}

bool existeCondicoesDeFecharCompra()
{
   bool temCondicoes =  (High[0] > valorIndicadorLinhaDoMeio(0));
   string condicoes = (temCondicoes == true)?"sim":"não";
   Comment(StringFormat("Existe condições de FECHAR COMPRA: %s %s %s ", DoubleToString(High[0],4), DoubleToString(valorIndicadorLinhaDoMeio(0),4),condicoes));
   return temCondicoes;
}

bool existeCondicoesDeAbrirVenda()
{   
   bool temCondicoes =  (High[0] > valorIndicadorLinhaDoMeio(0));
   string condicoes = (temCondicoes == true)?"sim":"não";
   Comment(StringFormat("Existe condições de ABRIR VENDA: %s %s %s ", DoubleToString(High[0],4), DoubleToString(valorIndicadorLinhaDeCima(0),4),condicoes));
   return temCondicoes;
}

bool existeCondicoesDeFecharVenda()
{
    bool temCondicoes = (High[0] < valorIndicadorLinhaDoMeio(0));
    string condicoes = (temCondicoes == true)?"sim":"não";
    Comment(StringFormat("Existe condições de FECHAR VENDA: %s %s %s ", DoubleToString(High[0],4), DoubleToString(valorIndicadorLinhaDoMeio(0),4),condicoes));
    return temCondicoes;
}

double  valorIndicadorLinhaDoMeio(int qualCandleStick)
{
   double R_Middle=iCustom(NULL,0,ind_name, 
                       Regr_Degree,Regr_Kstd,Regr_Bars,Regr_Shift, 
                       0,qualCandleStick); 
   return R_Middle;
}

double  valorIndicadorLinhaDeCima(int qualCandleStick)
{   
   double R_Upper=iCustom(NULL,0,ind_name, 
                       Regr_Degree,Regr_Kstd,Regr_Bars,Regr_Shift, 
                       1,qualCandleStick);
   return R_Upper;
}


  
double  valorIndicadorLinhaDeBaixo(int qualCandleStick)
{
   double R_Low=iCustom(NULL,0,ind_name, 
                       Regr_Degree,Regr_Kstd,Regr_Bars,Regr_Shift, 
                       2,qualCandleStick);
   return R_Low;
}
