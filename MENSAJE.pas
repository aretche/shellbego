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
UNIT MENSAJE;
INTERFACE
TYPE
ARRAYCHAR=ARRAY OF CHAR;

PROCEDURE GuardarDatosDAT(CADENA:STRING;VAR DAT:ARRAYCHAR);
PROCEDURE CopiarDatosDAT(INFO:ARRAYCHAR;VAR DAT:ARRAYCHAR);  
PROCEDURE InsertarDatos(CADENA:STRING;VAR DAT:ARRAYCHAR);  
PROCEDURE MostrarDatos(VAR DATOS:ARRAYCHAR);
PROCEDURE DejarBlanco(VAR DATOS:ARRAYCHAR);
PROCEDURE AgregarCaracter(VAR DAT:ARRAYCHAR;CARACTER:CHAR);

IMPLEMENTATION
PROCEDURE GuardarDatosDAT(CADENA:STRING;VAR DAT:ARRAYCHAR);
VAR
I,J:WORD;
BEGIN
      IF (HIGH(DAT)<1) THEN
          I:=1
	  ELSE
	      I:=HIGH(DAT)+1;
      IF (I=1) THEN
	  BEGIN
		   SETLENGTH(DAT,I+1); 
           DAT[I]:=#13;
           INC(I);
	  END;
      FOR J:=1 TO LENGTH(CADENA) DO
	  BEGIN
		   SETLENGTH(DAT,I+1);
		   DAT[I]:=CADENA[J];
		   INC(I);
	  END;
	  SETLENGTH(DAT,HIGH(DAT)+2);
	  DAT[I]:=#10;
	  DAT[I+1]:=#13;
END;

PROCEDURE AgregarCaracter(VAR DAT:ARRAYCHAR;CARACTER:CHAR);
VAR
I:CARDINAL;
BEGIN
	 IF (HIGH(DAT)<1) THEN
          I:=1
	 ELSE
	      I:=HIGH(DAT)+1;
	 IF (I=1) THEN
	  BEGIN
		   SETLENGTH(DAT,I+1); 
           DAT[I]:=#13;
           INC(I);
	  END;
	 SETLENGTH(DAT,I+1);
	 DAT[I]:=CARACTER;
END;

PROCEDURE CopiarDatosDAT(INFO:ARRAYCHAR;VAR DAT:ARRAYCHAR);  
VAR 
I,J:WORD;
BEGIN
	  IF (HIGH(DAT)<1) THEN
		  I:=1
	  ELSE
		  I:=HIGH(DAT)+1;
	  IF (I=1) THEN
	  BEGIN
		   SETLENGTH(DAT,I+1); 
		   DAT[I]:=#10;
		   INC(I);
	  END;
	  J:=1;
	  WHILE (J<=HIGH(INFO)-1) DO
	  BEGIN
		   SETLENGTH(DAT,I+1);
		   DAT[I]:=INFO[J];
		   INC(I);
		   INC(J);
	  END;
	  SETLENGTH(DAT,HIGH(DAT)+2);
	  DAT[I]:=#10;
	  DAT[I+1]:=#13;
END;

PROCEDURE InsertarDatos(CADENA:STRING;VAR DAT:ARRAYCHAR);  
VAR 
INFO:ARRAYCHAR;
BEGIN
	 GuardarDatosDAT(CADENA,INFO);
	 CopiarDatosDAT(INFO,DAT);
END;

PROCEDURE MostrarDatos(VAR DATOS:ARRAYCHAR); 
VAR
I: WORD;
BEGIN
	  IF HIGH(DATOS)>0 THEN
	  BEGIN
		   FOR I:= 1 TO HIGH(DATOS) DO
			  WRITE(DATOS[I]);	        	 
	  END;
	  DejarBlanco(DATOS);
END;

PROCEDURE DejarBlanco(VAR DATOS:ARRAYCHAR);
BEGIN
	 SETLENGTH(DATOS,0);
END;

END.
