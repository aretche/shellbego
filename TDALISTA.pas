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
UNIT TDALISTA;
INTERFACE
TYPE
TDATOS = STRING;
TPUNTEROL=^TNODOL;
TNODOL=RECORD
            INFO:TDATOS;
            SIG:TPUNTEROL;
       END;
TLISTA=RECORD
            CAB,AUX:TPUNTEROL;
            TAM:CARDINAL;
       END;

PROCEDURE CrearLista(VAR L:TLISTA;NOMBRE:STRING);
PROCEDURE CerrarLista(VAR L:TLISTA;NOMBRE:STRING);
FUNCTION Tamano(VAR L:TLISTA):CARDINAL;
FUNCTION Info(VAR L:TLISTA):TDATOS;
PROCEDURE Primero(VAR L:TLISTA);
PROCEDURE Siguiente(VAR L:TLISTA);
FUNCTION Fin(VAR L:TLISTA):BOOLEAN;
PROCEDURE Modif(VAR L:TLISTA;X:TDATOS);
PROCEDURE InsertarIPos(VAR L:TLISTA;X:TDATOS;POS:INTEGER);
PROCEDURE EliminarIPos(VAR L:TLISTA;VAR X:TDATOS;POS:INTEGER);
PROCEDURE EliminarUltimo(VAR L:TLISTA;VAR X:TDATOS);
PROCEDURE InsertarUltimo(VAR L:TLISTA;X:TDATOS);
FUNCTION NodoFinal(L:TLISTA):BOOLEAN;
PROCEDURE ConcatenarListas(VAR L:TLISTA;S:TLISTA);
FUNCTION ListaAString(L:TLISTA):STRING;

IMPLEMENTATION
USES CRT,SYSUTILS;

PROCEDURE CrearLista(VAR L:TLISTA;NOMBRE:STRING);
BEGIN
     L.CAB:=NIL;
     L.AUX:=NIL;
     L.TAM:=0;
END;

PROCEDURE CerrarLista(VAR L:TLISTA;NOMBRE:STRING);
VAR
AUX,ELIM:TPUNTEROL;
BEGIN
     AUX:=L.CAB;
     WHILE(AUX<>NIL)DO
     BEGIN
          ELIM:=AUX;
          AUX:=AUX^.SIG;
          DISPOSE(ELIM)
     END
END;

FUNCTION Tamano(VAR L:TLISTA):CARDINAL;
BEGIN
     Tamano:=L.TAM;
END;

FUNCTION Info(VAR L:TLISTA):TDATOS;
BEGIN
     Info:=L.AUX^.INFO;
END;

PROCEDURE Primero(VAR L:TLISTA);
BEGIN
     L.AUX:=L.CAB;
END;

PROCEDURE Siguiente(VAR L:TLISTA);
BEGIN
     L.AUX:=L.AUX^.SIG;
END;

FUNCTION Fin(VAR L:TLISTA):BOOLEAN;
BEGIN
     Fin:=L.AUX=NIL;
END;

PROCEDURE Modif(VAR L:TLISTA;X:TDATOS);
BEGIN
     L.AUX^.INFO:=X;
END;

PROCEDURE InsertarIPos(VAR L:TLISTA;X:TDATOS;POS:INTEGER);
VAR
   AUX:TPUNTEROL;
   ANT,ACT:TPUNTEROL;
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

PROCEDURE EliminarIPos(VAR L:TLISTA;VAR X:TDATOS;POS:INTEGER);
VAR
   AUX,AUX1:TPUNTEROL;
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

PROCEDURE InsertarUltimo(VAR L:TLISTA;X:TDATOS);
BEGIN
     InsertarIPos(L,X,TAMANO(L)+1);
END;

PROCEDURE EliminarUltimo(VAR L:TLISTA;VAR X:TDATOS);
BEGIN
     EliminarIPos(L,X,TAMANO(L))
END;

FUNCTION NodoFinal(L:TLISTA):BOOLEAN;
BEGIN
	 NodoFinal:=L.AUX^.SIG=NIL;
END;

PROCEDURE ConcatenarListas(VAR L:TLISTA;S:TLISTA);
BEGIN
	 WHILE NOT FIN(S) DO
	 BEGIN
		  InsertarUltimo(L,INFO(S));
		  Siguiente(S);
	 END;
END;

FUNCTION ListaAString(L:TLISTA):STRING;
VAR
CAD:STRING;
BEGIN
	 CAD:='';
	 PRIMERO(L);
	 WHILE NOT FIN(L) DO
	 BEGIN
		  CAD:=CAD+' '+INFO(L);
		  SIGUIENTE(L);
	 END;
	 ListaAString:=CAD;
END;

END.


