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
UNIT TDALISTAPROCESOS;
INTERFACE
USES TDAREGISTROPROCESO;
TYPE
TDATOSPROCESO = PROCESO;
TPUNTEROLPROCESO=^TNODOLPROCESO;
TNODOLPROCESO=RECORD
            INFO:TDATOSPROCESO;
            SIG:TPUNTEROLPROCESO;
       END;
TLISTAPROCESO=RECORD
            CAB,AUX:TPUNTEROLPROCESO;
            TAM:CARDINAL;
       END;

PROCEDURE CrearListaP(VAR L:TLISTAPROCESO;NOMBRE:STRING);
PROCEDURE CerrarListaP(VAR L:TLISTAPROCESO;NOMBRE:STRING);
FUNCTION TamanoP(VAR L:TLISTAPROCESO):CARDINAL;
FUNCTION InfoP(VAR L:TLISTAPROCESO):TDATOSPROCESO;
PROCEDURE PrimeroP(VAR L:TLISTAPROCESO);
PROCEDURE SiguienteP(VAR L:TLISTAPROCESO);
FUNCTION FinP(VAR L:TLISTAPROCESO):BOOLEAN;
PROCEDURE ModifP(VAR L:TLISTAPROCESO;X:TDATOSPROCESO);
PROCEDURE InsertarIPosP(VAR L:TLISTAPROCESO;X:TDATOSPROCESO;POS:INTEGER);
PROCEDURE EliminarIPosP(VAR L:TLISTAPROCESO;VAR X:TDATOSPROCESO;POS:INTEGER);
PROCEDURE EliminarUltimoP(VAR L:TLISTAPROCESO;VAR X:TDATOSPROCESO);
PROCEDURE InsertarUltimoP(VAR L:TLISTAPROCESO;X:TDATOSPROCESO);
FUNCTION En(VAR L:TLISTAPROCESO;POSICION:CARDINAL):TDATOSPROCESO;
PROCEDURE EnPoner(VAR L:TLISTAPROCESO;POSICION:CARDINAL;X:TDATOSPROCESO);
FUNCTION BusqNT(L:TLISTAPROCESO;NUM:CARDINAL):PROCESO;
FUNCTION BusPID(L:TLISTAPROCESO;PID:LONGINT):PROCESO;

IMPLEMENTATION
USES CRT,SYSUTILS;

PROCEDURE CrearListaP(VAR L:TLISTAPROCESO;NOMBRE:STRING);
BEGIN
     L.CAB:=NIL;
     L.AUX:=NIL;
     L.TAM:=0;
END;

PROCEDURE CerrarListaP(VAR L:TLISTAPROCESO;NOMBRE:STRING);
VAR
AUX,ELIM:TPUNTEROLPROCESO;
BEGIN
     AUX:=L.CAB;
     WHILE(AUX<>NIL)DO
     BEGIN
          ELIM:=AUX;
          AUX:=AUX^.SIG;
          DISPOSE(ELIM)
     END
END;

FUNCTION TamanoP(VAR L:TLISTAPROCESO):CARDINAL;
BEGIN
     TamanoP:=L.TAM;
END;

FUNCTION InfoP(VAR L:TLISTAPROCESO):TDATOSPROCESO;
BEGIN
     InfoP:=L.AUX^.INFO;
END;

PROCEDURE PrimeroP(VAR L:TLISTAPROCESO);
BEGIN
     L.AUX:=L.CAB;
END;

PROCEDURE SiguienteP(VAR L:TLISTAPROCESO);
BEGIN
     L.AUX:=L.AUX^.SIG;
END;

FUNCTION FinP(VAR L:TLISTAPROCESO):BOOLEAN;
BEGIN
     FINP:=L.AUX=NIL;
END;

PROCEDURE ModifP(VAR L:TLISTAPROCESO;X:TDATOSPROCESO);
BEGIN
     L.AUX^.INFO:=X;
END;

PROCEDURE InsertarIPosP(VAR L:TLISTAPROCESO;X:TDATOSPROCESO;POS:INTEGER);
VAR
   AUX:TPUNTEROLPROCESO;
   ANT,ACT:TPUNTEROLPROCESO;
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

PROCEDURE InsertarUltimoP(VAR L:TLISTAPROCESO;X:TDATOSPROCESO);
BEGIN
     InsertarIPosP(L,X,TAMANOP(L)+1);
END;

PROCEDURE EliminarIPosP(VAR L:TLISTAPROCESO;VAR X:TDATOSPROCESO;POS:INTEGER);
VAR
AUX,AUX1:TPUNTEROLPROCESO;
BEGIN
     IF (L.CAB<>NIL)AND(POS = 1) THEN
     BEGIN
          AUX:=L.CAB;
          DEC(L.TAM);
          X:=AUX^.INFO;
          L.CAB:=L.CAB^.SIG;
          DISPOSE(AUX);
     END
     ELSE
     BEGIN
         IF(L.CAB<>NIL)THEN
         BEGIN
              AUX:=L.CAB;
              AUX1:=AUX^.SIG;
              WHILE (AUX1<>NIL) AND (POS>2)DO
              BEGIN
                   AUX := AUX^.SIG;
                   AUX1 := AUX^.SIG;
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

PROCEDURE EliminarUltimoP(VAR L:TLISTAPROCESO;VAR X:TDATOSPROCESO);
BEGIN
     EliminarIPosP(L,X,TAMANOP(L))
END;

FUNCTION En(VAR L:TLISTAPROCESO;POSICION:CARDINAL):TDATOSPROCESO;
BEGIN
     PRIMEROP(L);
     DEC(POSICION);
     WHILE((NOT FINP(L))AND(POSICION>0))DO
     BEGIN
		  SIGUIENTEP(L);
		  DEC(POSICION);
     END;
     En:=INFOP(L);
END;

PROCEDURE EnPoner(VAR L:TLISTAPROCESO;POSICION:CARDINAL;X:TDATOSPROCESO);
VAR
AUX:TDATOSPROCESO;
BEGIN
     EliminarIPosP(L,AUX,POSICION);
     InsertarIPosP(L,X,POSICION);
END;

FUNCTION BusqNT(L:TLISTAPROCESO;NUM:CARDINAL):PROCESO;
VAR
P:PROCESO;
BEGIN
	 FILLCHAR(P,SizeOf(P),#0);
	 PrimeroP(L);
	 WHILE ((NOT FinP(L))AND(NUM<>NumeroTrabajo(InfoP(L))))DO
		SiguienteP(L);
	 IF(NOT FinP(L))THEN
		 BusqNT:=InfoP(L)
	 ELSE
		 BusqNT:=P;
END;

FUNCTION BusPID(L:TLISTAPROCESO;PID:LONGINT):PROCESO;
VAR
P:PROCESO;
BEGIN
	 FILLCHAR(P,SizeOf(P),#0);
	 PrimeroP(L);
	 WHILE ((NOT FinP(L))AND(PID<>DevolverPID(InfoP(L))))DO
		SiguienteP(L);
	 IF(NOT FinP(L))THEN
		 BusPID:=InfoP(L)
	 ELSE
		 BusPID:=P;
END;

END.


