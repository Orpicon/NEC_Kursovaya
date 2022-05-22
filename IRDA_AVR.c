/*
 * IRDA.c
 *
 * Created: 10.03.2022 15:55:26
 * Author : Vitaly
 */ 

#include <avr/io.h>
#include <avr/interrupt.h>

#define StopTim	TIMSK &= ~(1 << TOIE0); 
#define StartTim	TIMSK |= (1 << TOIE0);	

int startOver, firstCom, nextCom,i,Com1, Com=0;


ISR(TIMER0_OVF_vect) 
{
	if (startOver ==0) { startOver = 1; }
	else {
		firstCom = 0; 
		startOver = 0; 
		StopTim; 
	}
}

ISR (INT0_vect)
{
	if (firstCom == 0) { 
		nextCom = 0;
		firstCom = 1;
		StartTim; 
		} else {  		

		if(TCNT0>0x69 && TCNT0<0x7F){ 
			i = 32; 
		}

		else if(TCNT0>0x03 && TCNT0<0x0B){ 
			if ((i>0) && (i<9)) Com1 &= ~(1<<(i-1));
			if ((i>8) && (i<17)) Com |= (1<<(i-9)); 
			i--;
		}
		
		else if(TCNT0>0x0C && TCNT0<0x14){ 
			if ((i>0) && (i<9)) Com1 |= (1<<(i-1)); 
			if ((i>8) && (i<17)) Com &= ~(1<<(i-9)); 
			i--;
		}

		else if(TCNT0>0x54 && TCNT0<0x5C){ 
			nextCom = 1; 
		}
		
		else if (i==0) { 
			StopTim; 
			nextCom = 1; 
			firstCom = 0; 
			startOver = 0;	
		}
	}
	TCNT0 = 0; 
}



int main(void)
{	
	GIMSK|= (1<<INT0); 
	MCUCR|=(1<<ISC01)|(0<<ISC00); 
	
	TCCR0B|=(1<<CS02)|(1<<CS00); 
	DDRB=0xff;
	sei();   
    while (1) 
    {
		if (nextCom) { 
			nextCom = 0;	
			if (Com == Com1) {PORTB=Com1;} 
				} 
		
    }
}

