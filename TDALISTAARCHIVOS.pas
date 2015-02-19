{SHELLBEGO - BRACCO ESCALANTE GARCIA OBELAR
SHELLBEGO is Copyright (C) 2014-2015 Free Software Foundation, Inc.	
SHELLBEGO es un intérprete primitivo de lenguajes de comandos que ejecuta órdenes leídas de la entrada estándar.
SHELLBEGO fue desarrollada como trabajo final de la materia Sistemas Operativos FRCU - UTN.

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
    Also add information on how to contact you by electronic and paper mail.}
UNIT TDALISTAARCHIVOS;
INTERFACE
USES CRT,SYSUTILS,BaseUnix, Unix, Unixtype,DateUtils,users,unixutil;

TYPE
TDATOSA=RECORD
			  REGSTAT:stat;
			  CLAVE:STRING;
		END;
TPUNTEROLA=^TNODOLA;
TNODOLA=RECORD
              INFO:TDATOSA;
              SIG:TPUNTEROLA;
		END;
TLISTAA=RECORD
              CAB,AUX:TPUNTEROLA;
              TAM:CARDINAL;
		END;

PROCEDURE CrearListaA(VAR L:TLISTAA;NOMBRE:STRING);
PROCEDURE CerrarListaA(VAR L:TLISTAA;NOMBRE:STRING);
FUNCTION TamanoA(VAR L:TLISTAA):CARDINAL;
FUNCTION InfoA(VAR L:TLISTAA):TDATOSA;
FUNCTION RegStat(VAR X:TDATOSA):stat;//NUEVO
FUNCTION Clave(VAR X:TDATOSA):string; 
PROCEDURE PrimeroA(VAR L:TLISTAA);
PROCEDURE SiguienteA(VAR L:TLISTAA);
FUNCTION FinA(VAR L:TLISTAA):BOOLEAN;
PROCEDURE ModifA(VAR L:TLISTAA;X:TDATOSA);
PROCEDURE InsertarIPosA(VAR L:TLISTAA;X:TDATOSA;POS:INTEGER);
PROCEDURE EliminarIPosA(VAR L:TLISTAA;VAR X:TDATOSA;POS:INTEGER);
PROCEDURE EliminarUltimoA(VAR L:TLISTAA;VAR X:TDATOSA);
PROCEDURE InsertarUltimoA(VAR L:TLISTAA;X:TDATOSA);
PROCEDURE ConcatenarA(VAR L:TLISTAA;VAR L2:TLISTAA);
PROCEDURE InsertarOrdenadoA(VAR L: TLISTAA; X:TDATOSA);
PROCEDURE ListarListas(L:TLISTAA);
PROCEDURE OrdenarLista(var L:TLISTAA);

IMPLEMENTATION

PROCEDURE CrearListaA(VAR L:TLISTAA;NOMBRE:STRING);
BEGIN
     L.CAB:=NIL;
     L.AUX:=NIL;
     L.TAM:=0;
END;

PROCEDURE CerrarListaA(VAR L:TLISTAA;NOMBRE:STRING);
VAR
AUX,ELIM:TPUNTEROLA;
BEGIN
     AUX:=L.CAB;
     WHILE(AUX<>NIL)DO
     BEGIN
          ELIM:=AUX;
          AUX:=AUX^.SIG;
          DISPOSE(ELIM)
     END
END;

FUNCTION TamanoA(VAR L:TLISTAA):CARDINAL;
BEGIN
     TamanoA:=L.TAM;
END;

FUNCTION InfoA(VAR L:TLISTAA):TDATOSA;
BEGIN
     InfoA:=L.AUX^.INFO;
END;

FUNCTION RegStat(VAR X:TDATOSA):stat;
BEGIN
     RegStat:=X.REGSTAT;
END;

FUNCTION Clave(VAR X:TDATOSA):string;
BEGIN
     Clave:=X.CLAVE;
END;

PROCEDURE PrimeroA(VAR L:TLISTAA);
BEGIN
     L.AUX:=L.CAB;
END;

FUNCTION FinA(VAR L:TLISTAA):BOOLEAN;
BEGIN
     FinA:=TAMANOA(L)=0;
END;

PROCEDURE SiguienteA(VAR L:TLISTAA);
BEGIN
     L.AUX:=L.AUX^.SIG;
END;

PROCEDURE ModifA(VAR L:TLISTAA;X:TDATOSA);
BEGIN
     L.AUX^.INFO:=X;
END;

PROCEDURE InsertarIPosA(VAR L:TLISTAA;X:TDATOSA;POS:INTEGER);
VAR
   AUX:TPUNTEROLA;
   ANT,ACT:TPUNTEROLA;
BEGIN
   NEW(AUX);
   INC(L.TAM);
   AUX^.INFO:=X;
   IF (L.CAB=NIL)OR (POS = 1) THEN
      BEGIN
           AUX^.SIG:=L.CAB;
           L.CAB:=AUX;
      END
    ELSE
     BEGIN
         ANT:=L.CAB;
         ACT:=L.CAB^.SIG;
         WHILE (ACT<>NIL) AND (POS>1)DO
         BEGIN
             ANT:=ACT;
             ACT:=ACT^.SIG;
             DEC(POS);
         END;
         AUX^.SIG:=ACT;
         ANT^.SIG:=AUX;
      END;
END;

PROCEDURE EliminarIPosA(VAR L:TLISTAA;VAR X:TDATOSA;POS:INTEGER);
VAR
   AUX,AUX1:TPUNTEROLA;
BEGIN //con L.CAB=NIL no debe haccer nada
     AUX:=L.CAB;
     IF (L.CAB<>NIL)AND(POS = 1) THEN
     BEGIN
          DEC(L.TAM);
          X:=AUX^.INFO;
          L.CAB:=L.CAB^.SIG;
          DISPOSE(AUX);
     END
     ELSE
     BEGIN
         IF(L.CAB<>NIL)THEN
         BEGIN
              AUX1:=AUX^.SIG;
              WHILE (AUX1<>NIL) AND (POS>2)DO 
              BEGIN
                   AUX := AUX^.SIG;
                   AUX1 := AUX^.SIG; //esto está bien, porque AUX cambió en la linea anterior
                   DEC(POS);
              END;
              IF(POS=2)THEN
              BEGIN
                   DEC(L.TAM);
                   AUX^.SIG:= AUX1^.SIG;
                   X:=AUX1^.INFO;
                   DISPOSE(AUX1);
              END;
         END;
     END;
END;


PROCEDURE EliminarUltimoA(VAR L:TLISTAA;VAR X:TDATOSA);
BEGIN
     ELIMINARiPOSA(L,X,TAMANOA(L))
END;

PROCEDURE InsertarUltimoA(VAR L:TLISTAA;X:TDATOSA);
BEGIN
     INSERTARiPOSA(L,X,TAMANOA(L)+1);
END;

PROCEDURE ConcatenarA(VAR L:TLISTAA;VAR L2:TLISTAA);
VAR
AUX:TPUNTEROLA;
BEGIN
     AUX:=L.CAB;
     WHILE(AUX<>NIL)DO
        AUX:=AUX^.SIG;
     AUX:=L2.CAB;
END;


PROCEDURE InsertarOrdenadoA(VAR L: TLISTAA; X:TDATOSA);  //NUEVO
var ANT,ACT,AUX:TPUNTEROLA;
XACTUAL,XNUEVO:STRING;
BEGIN
	NEW(AUX);
	INC(L.TAM);
	AUX^.INFO:=X;
	XACTUAL:='';
	XNUEVO:='';
	IF L.CAB<>NIL THEN
	BEGIN
		IF (CLAVE(L.CAB^.INFO)[1]='.') THEN //OSEA SI EL PRIMER CARACTER DEL STRING ES UN PUNTO (.)
			XACTUAL:=COPY(CLAVE(L.CAB^.INFO),2,length(CLAVE(L.CAB^.INFO)))
		ELSE
			XACTUAL:=CLAVE(L.CAB^.INFO);
		IF (CLAVE(X)[1]='.') THEN
			XNUEVO:= COPY(CLAVE(X),2,LENGTH(CLAVE(X)))
		ELSE
			XNUEVO:=CLAVE(X);
	END;
   	IF (L.CAB=NIL) OR (upCase(XACTUAL) > upCase(XNUEVO)) THEN
	BEGIN
           AUX^.SIG:=L.CAB;
           L.CAB:=AUX;
      	END
    	ELSE
	BEGIN
		ANT:=L.CAB;
         	ACT:=L.CAB^.SIG;
		IF (ACT<>NIL) THEN
		BEGIN
			IF (CLAVE(ACT^.INFO)[1]='.') THEN //OSEA SI EL PRIMER CARACTER DEL STRING ES UN PUNTO (.)
				XACTUAL:=COPY(CLAVE(ACT^.INFO),2,length(CLAVE(ACT^.INFO)))
			ELSE
				XACTUAL:=CLAVE(ACT^.INFO);
         		WHILE (ACT<>NIL) AND (upCase(XACTUAL) <= upCase(XNUEVO))DO
         		BEGIN
             			ANT:=ACT;
             			ACT:=ACT^.SIG;
				IF (ACT<>NIL) AND (CLAVE(ACT^.INFO)[1]='.') THEN //OSEA SI EL PRIMER CARACTER DEL STRING ES UN PUNTO (.)
					XACTUAL:=COPY(CLAVE(ACT^.INFO),2,length(CLAVE(ACT^.INFO)))
				ELSE
					IF (ACT<>NIL) THEN
						XACTUAL:=CLAVE(ACT^.INFO);
         		END;
		END;
         	AUX^.SIG:=ACT;
         	ANT^.SIG:=AUX;
      	END;
END;

{PROCEDURE INSERTARORDENADOA(VAR L: TLISTAA; X:TDATOSA);  //este es con stat //NUEVO
var ANT,ACT,AUX:TPUNTEROLA;
BEGIN
	NEW(AUX);
	INC(L.TAM);
	AUX^.INFO:=X;
   	IF (L.CAB=NIL)OR (UPCASE(CLAVE(L.CAB^.INFO)) > UPCASE(CLAVE(X))) THEN
	BEGIN
           AUX^.SIG:=L.CAB;
           L.CAB:=AUX;
      	END
    	ELSE
	BEGIN
		ANT:=L.CAB;
         	ACT:=L.CAB^.SIG;
         	WHILE (ACT<>NIL) AND (UPCASE(CLAVE(ACT^.INFO)) <= UPCASE(CLAVE(X)))DO
         	BEGIN
             		ANT:=ACT;
             		ACT:=ACT^.SIG;
         	END;
         	AUX^.SIG:=ACT;
         	ANT^.SIG:=AUX;
      	END;
END;}

PROCEDURE ListarListas(L:TLISTAA);
VAR X:TDATOSA;
BEGIN
	WHILE NOT(FINA(L)) DO
	BEGIN
		 ELIMINARIPOSA(L,X,1);
		 WRITELN(CLAVE(X));
	END;
END;

PROCEDURE OrdenarLista(var L:TLISTAA);
VAR LISTAAUX:TLISTAA;
X:TDATOSA;
BEGIN
	CREARLISTAA(LISTAAUX,'');
	WHILE NOT(FINA(L)) DO
	BEGIN
		ELIMINARiPOSA(L,X,1);
		INSERTARORDENADOA(LISTAAUX,X);
	END;
	L:=LISTAAUX;		
END;


END.


