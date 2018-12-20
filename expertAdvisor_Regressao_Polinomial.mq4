// 
/*
Publicado em 14 de abr de 2016
Hoy veremos en detalle cómo se usa el comando iCustom para convocar un dato de un indicador 
personalizado en otro programa como un Expert Adviser, primero creo un indicador customizado 
simple para luego usarlo en un Expert que compre o venda dependiendo del cierre vs un promedio móvil especial 
(nuestro indicador customizado)
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
      if(existeCondicoesDeCompra() == true)
      {
         bool r = OrderSend(NULL,0,Lots, Ask, 20, 0, 0, "Expert Advisor Abre COMPRA", MagicNum, 0,clrAliceBlue);
      }
      if(existeCondicoesDeVenda() == true)
      {
        bool r = OrderSend(NULL,1,Lots, Bid, 20, 0, 0, "Expert Advisor Abre VENDA", MagicNum, 0, clrBlueViolet);
      }
   }
   //Já tem um trade no ar, então monitorar a saída deste trade
   if(ticketAOperar > -1)
   {
      if(OrderSelect(ticketAOperar, SELECT_BY_TICKET, MODE_TRADES))
      {
         //se é uma compra e necessito buscar uma venda
         if(OrderType() == OP_BUY && existeCondicoesDeVenda() == true)
         {
            bool r = OrderClose(ticketAOperar, OrderLots(), OrderClosePrice(), 20, clrNONE);
         }
         //se é uma venda e necessito buscar uma compra
         if(OrderType() == OP_SELL && existeCondicoesDeCompra() == true)
         {
           bool r = OrderClose(ticketAOperar, OrderLots(), OrderClosePrice(), 20, clrNONE);
         }
      }
   }
}

int getTicketAOperar()
{  
   for(int op = 0; op < OrdersTotal(); op++)
   {
      bool r = OrderSelect(op,SELECT_BY_POS,MODE_TRADES);
      if(OrderMagicNumber() == MagicNum && OrderSymbol() == Symbol())
      {
         return OrderTicket();
      }
      
   }
   return (-1);//não encontrou nada
}

bool existeCondicoesDeCompra()
{
  //se tiver tudo subindo abre posição de compra
   bool linhaCimaSubindo = valorIndicadorLinhaDeCima(0) > valorIndicadorLinhaDeCima(2);
   bool linhaMeioSubindo = valorIndicadorLinhaDoMeio(0) > valorIndicadorLinhaDoMeio(2);
   bool linhaDeBaixoSubindo = valorIndicadorLinhaDeBaixo(0) > valorIndicadorLinhaDeBaixo(2);
   if(linhaCimaSubindo && linhaMeioSubindo && linhaDeBaixoSubindo){
   return true;
   }
   else{
     return false;
   }
   
  /* if( Close[1] < valor)
   {
      return true;
   }
   else
   {
       return false;
   }*/
}

bool existeCondicoesDeVenda()
{
   double valor = valorIndicadorLinhaDeCima(0);
   bool linhaCimaDescendo = valorIndicadorLinhaDeCima(0) < valorIndicadorLinhaDeCima(2);
   bool linhaMeioDescendo = valorIndicadorLinhaDoMeio(0) < valorIndicadorLinhaDoMeio(2);
   bool linhaDeBaixoDescendo = valorIndicadorLinhaDeBaixo(0) < valorIndicadorLinhaDeBaixo(2);
   if(linhaCimaDescendo && linhaMeioDescendo && linhaDeBaixoDescendo){
   return true;
   }
   else{
     return false;
   }
   /*if( Close[1] >= valor)
   {
      return true;
   }
   else
   {
       return false;
   }*/
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
