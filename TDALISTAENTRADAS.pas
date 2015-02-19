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
UNIT TDALISTAENTRADAS;
INTERFACE
TYPE
TDATOSENTRADA = STRING;
TPUNTEROLENTRADA=^TNODOLENTRADA;
TNODOLENTRADA=RECORD
            INFO:TDATOSENTRADA;
            ANT,SIG:TPUNTEROLENTRADA;
              END;
TLISTAENTRADA=RECORD
            CAB,AUX,FIN:TPUNTEROLENTRADA;
            TAM:CARDINAL;
              END;

PROCEDURE CrearListaE(VAR L:TLISTAENTRADA;NOMBRE:STRING);
PROCEDURE CerrarListaE(VAR L:TLISTAENTRADA;NOMBRE:STRING);
FUNCTION TamanoE(VAR L:TLISTAENTRADA):CARDINAL;
FUNCTION InfoE(VAR L:TLISTAENTRADA):TDATOSENTRADA;
PROCEDURE PrimeroE(VAR L:TLISTAENTRADA);
PROCEDURE SiguienteE(VAR L:TLISTAENTRADA);
FUNCTION FinE(VAR L:TLISTAENTRADA):BOOLEAN;
FUNCTION InicioE(VAR L:TLISTAENTRADA):BOOLEAN;
PROCEDURE AnteriorE(VAR L:TLISTAENTRADA);
PROCEDURE UltimoE(VAR L:TLISTAENTRADA);
PROCEDURE InsertarUltimoE(VAR L:TLISTAENTRADA;X:TDATOSENTRADA);
PROCEDURE ListarEntradas(L:TLISTAENTRADA);
FUNCTION SigIsNil(L:TLISTAENTRADA):BOOLEAN;
FUNCTION AntIsNil(L:TLISTAENTRADA):BOOLEAN;
PROCEDURE AgregarEntrada(VAR L:TLISTAENTRADA;ENTRADA:STRING);


IMPLEMENTATION
USES CRT,SYSUTILS,MATH;

PROCEDURE CrearListaE(VAR L:TLISTAENTRADA;NOMBRE:STRING);
BEGIN
     L.CAB:=NIL;
     L.AUX:=NIL;
     L.FIN:=NIL;
     L.TAM:=0;
END;

PROCEDURE CerrarListaE(VAR L:TLISTAENTRADA;NOMBRE:STRING);
VAR
AUX,ELIM:TPUNTEROLENTRADA;
BEGIN
     AUX:=L.CAB;
     WHILE(AUX<>NIL)DO
     BEGIN
          ELIM:=AUX;
          AUX:=AUX^.SIG;
          DISPOSE(ELIM)
     END
END;

FUNCTION TamanoE(VAR L:TLISTAENTRADA):CARDINAL;
BEGIN
     TamanoE:=L.TAM;
END;

FUNCTION InfoE(VAR L:TLISTAENTRADA):TDATOSENTRADA;
BEGIN
     InfoE:=L.AUX^.INFO;
END;

PROCEDURE PrimeroE(VAR L:TLISTAENTRADA);
BEGIN
     L.AUX:=L.CAB;
END;

PROCEDURE SiguienteE(VAR L:TLISTAENTRADA);
BEGIN
     L.AUX:=L.AUX^.SIG;
END;

FUNCTION FinE(VAR L:TLISTAENTRADA):BOOLEAN;
BEGIN
     FinE:=(L.AUX=NIL);
END;

FUNCTION InicioE(VAR L:TLISTAENTRADA):BOOLEAN;
BEGIN
     InicioE:=L.AUX=NIL;
END;

PROCEDURE AnteriorE(VAR L:TLISTAENTRADA);
BEGIN
	 L.AUX:=L.AUX^.ANT
END;

PROCEDURE UltimoE(VAR L:TLISTAENTRADA);
BEGIN
     L.AUX:=L.FIN;
END;

PROCEDURE InsertarUltimoE(VAR L:TLISTAENTRADA;X:TDATOSENTRADA);
VAR
AUX:TPUNTEROLENTRADA;
BEGIN
   NEW(AUX);
   INC(L.TAM);
   AUX^.INFO:=X;
   IF (L.CAB=NIL)THEN
   BEGIN
 	    AUX^.ANT:=L.CAB;
	    AUX^.SIG:=L.CAB;
	    L.CAB:=AUX;
	    L.FIN:=AUX;
   END
   ELSE
   BEGIN
        AUX^.ANT:=L.FIN;
        AUX^.SIG:=L.FIN^.SIG;
        L.FIN^.SIG:=AUX;
        L.FIN:=AUX;
   END;
END;

FUNCTION Espacios(N:CARDINAL):STRING;
VAR
AUX:STRING;
I:CARDINAL;
BEGIN
     AUX:='';
     IF(N>0)THEN
     BEGIN
		  FOR I:=1 TO N DO
             AUX:=' '+AUX;
     END;
     Espacios:=AUX;
END;

PROCEDURE ListarEntradas(L:TLISTAENTRADA);
VAR
NUM:CARDINAL;
BEGIN
	 PrimeroE(L);
	 NUM:=1;
	 WHILE NOT(FinE(L)) DO
	 BEGIN
		  WRITELN(NUM:(FLOOR(log10(TamanoE(L)))+2),'  ',InfoE(L));
		  SiguienteE(L);
		  INC(NUM);
	 END;
END;

FUNCTION SigIsNil(L:TLISTAENTRADA):BOOLEAN;
BEGIN
	 SigIsNil:=L.AUX^.SIG=NIL;
END;

FUNCTION AntIsNil(L:TLISTAENTRADA):BOOLEAN;
BEGIN
	 AntIsNil:=L.AUX^.ANT=NIL;
END;

PROCEDURE AgregarEntrada(VAR L:TLISTAENTRADA;ENTRADA:STRING);
BEGIN
	 ULTIMOE(L);
	 IF((FinE(L))OR(ENTRADA<>INFOE(L)))THEN
		INSERTARULTIMOE(L,ENTRADA);
END;

END.


