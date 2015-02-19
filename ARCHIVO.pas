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
UNIT ARCHIVO;
{$mode objfpc}
INTERFACE
USES MENSAJE,TDALISTAENTRADAS;
TYPE
TArchivoRedireccion=^File;
TDatosArchivo=CHAR;
TArchivo=FILE OF TDatosArchivo;

FUNCTION CrearArchivo(RUTA:STRING):LONGINT;
FUNCTION CrearAbrirEscritura(RUTA:STRING):LONGINT;
FUNCTION CrearAbrirLectura(RUTA:STRING):LONGINT;
PROCEDURE CerrarArchivo(FD:LONGINT);
PROCEDURE EscribirFinArchivo(RUTA:STRING;INFORMACION:ARRAYCHAR);
PROCEDURE ReEscribirFinArchivo(RUTA:STRING;INFORMACION:ARRAYCHAR);
PROCEDURE LeerArchivoADAT(RUTA:STRING;VAR INFORMACION:ARRAYCHAR);
PROCEDURE EscribirStringArchivo(RUTA:STRING;INFORMACION:STRING);
FUNCTION TamanoArchivo(RUTA:STRING):LONGINT;
PROCEDURE CambiarSalidaAArchivo(VAR F:TArchivoRedireccion;VAR TempHOut:LONGINT;OPCION:CHAR;RUTA:STRING);
PROCEDURE CambiarSalidaAPantalla(VAR F:TArchivoRedireccion;VAR TempHOut:LONGINT);
PROCEDURE CambiarEntradaAArchivo(VAR F:TArchivoRedireccion;VAR TempHOut:LONGINT;RUTA:STRING);
PROCEDURE CambiarEntradaATeclado(VAR F:TArchivoRedireccion;VAR TempHOut:LONGINT);

IMPLEMENTATION
//ARCHIVO
USES BASEUNIX,Sysutils;
FUNCTION CrearArchivo(RUTA:STRING):LONGINT;
BEGIN
	 CrearArchivo:=FPOpen(RUTA,O_Creat);
END;

FUNCTION CrearAbrirEscritura(RUTA:STRING):LONGINT;
BEGIN
	 CrearAbrirEscritura:=FPOpen(RUTA,O_WrOnly OR O_Creat);
END;

FUNCTION CrearAbrirLectura(RUTA:STRING):LONGINT;
Begin
	 CrearAbrirLectura:=FPOpen(RUTA,O_RdOnly OR O_Creat);
end;

PROCEDURE CerrarArchivo(FD:LONGINT);
BEGIN
     fpClose(FD);
END;

PROCEDURE EscribirFinArchivo(RUTA:STRING;INFORMACION:ARRAYCHAR);
VAR
FD:LONGINT;
I:CARDINAL;
BEGIN
	 FD:=CrearAbrirEscritura(RUTA);
	 IF FPLSEEK(FD,0,Seek_end)=-1 then
	     WRITELN('¡ERROR EN EL ARCHIVO!');
	 If (FD>0) then
	 BEGIN
	      IF HIGH(INFORMACION)>0 THEN
              FOR I:=2 TO HIGH(INFORMACION) DO
                 IF (FPWRITE(FD,INFORMACION[I],1))=-1 THEN
		   	     BEGIN
		   	          WRITELN ('¡ERROR AL ESCRIBIR EN EL ARCHIVO!');	  
		   	          HALT(2);    
		   	     END;      
	 END;
	 CerrarArchivo(FD);
END;

FUNCTION TamanoArchivo(RUTA:STRING):LONGINT;
VAR
INFO:STAT;
BEGIN
	 IF (FPStat(RUTA,info)<>0) THEN
	 BEGIN
		  IF (fpgeterrno=2) THEN
			  TamanoArchivo:=0
		  ELSE
		  BEGIN
			   Writeln('¡FALLO EN OBTENER INFORMACIÓN ARCHIVO!');
			   TamanoArchivo:=-1;
			   halt (1);
		  END;
	 END
	 ELSE
		 TamanoArchivo:=info.st_size;
END;

PROCEDURE ArchivoEnNulo(FD:LONGINT);
BEGIN
	 IF(FpFtruncate(FD,0)<>0)THEN
	    WRITELN('¡ERROR CON DEJAR ARHIVO EN BLANCO!');
END;

PROCEDURE ReEscribirFinArchivo(RUTA:STRING;INFORMACION:ARRAYCHAR);
VAR
FD:LONGINT;
I:CARDINAL;
BEGIN
	 FD:=CrearAbrirEscritura(RUTA);
	 ArchivoEnNULO(FD);
	 IF FPLSEEK(FD,0,Seek_end)=-1 then
	     WRITELN('¡ERROR EN EL ARCHIVO!');
	 If (FD>0) then
	 BEGIN
	      IF HIGH(INFORMACION)>0 THEN
              FOR I:=2 TO HIGH(INFORMACION) DO
                 IF (FPWRITE(FD,INFORMACION[I],1))=-1 THEN
		   	     BEGIN
		   	          WRITELN ('¡ERROR AL ESCRIBIR EN EL ARCHIVO!');	  
		   	          HALT(2);    
		   	     END;      
	 END;
	 CerrarArchivo(FD);
END;

PROCEDURE LeerArchivoADAT(RUTA:STRING;VAR INFORMACION:ARRAYCHAR);
VAR
FD:LONGINT;
I:CARDINAL;
CARACTER:CHAR;
BEGIN
	 DejarBlanco(INFORMACION);
	 FD:=CrearAbrirLectura(RUTA);
	 IF (FD>0) THEN
	 BEGIN
		  IF(TamanoArchivo(RUTA)>0)THEN
		     FOR I:=1 TO TamanoArchivo(RUTA) DO
		     BEGIN
				  IF(FPREAD(FD,CARACTER,1)<0)THEN
				  BEGIN
					   WRITELN ('¡ERROR LEYENDO ARCHIVO!');
					   HALT(2);
				  END;
				  AgregarCaracter(INFORMACION,CARACTER);
			 END;
	 END;
	 CerrarArchivo(FD);	 
END;

PROCEDURE EscribirStringArchivo(RUTA:STRING;INFORMACION:STRING);
VAR
DAT:ARRAYCHAR;
BEGIN
	 GuardarDatosDAT(INFORMACION,DAT);
	 EscribirFinArchivo(RUTA,DAT);
END;

//REDIRECCIONAR SALIDA --> ARCHIVO
FUNCTION ExisteArchivo(RUTA: STRING):BOOLEAN;
VAR
F: FILE;
BEGIN
    {$I-}
    ASSIGN (F,RUTA);
    RESET (F);
    {$I+}
    ExisteArchivo:=(IORESULT=0)AND(RUTA<>'');
    CLOSE (F);
END;

PROCEDURE CambiarSalidaAArchivo(VAR F:TArchivoRedireccion;VAR TempHOut:LONGINT;OPCION:CHAR;RUTA:STRING);
BEGIN
     NEW(F);
     ASSIGN(F^,RUTA);
     IF (OPCION='1')OR(NOT EXISTEARCHIVO(RUTA))THEN {>}
         REWRITE(F^)
     ELSE			   								{>>}
	 BEGIN
		  RESET(F^);
		  SEEK(F^,SIZEOF(F^));
	 END;
     TEMPHOUT:=FPDUP(STDOUTPUTHANDLE);
     FPDUP2(FILEREC(F^).HANDLE,STDOUTPUTHANDLE);
END;

PROCEDURE CambiarSalidaAPantalla(VAR F:TArchivoRedireccion;VAR TempHOut:LONGINT);
BEGIN
     FPDUP2(TEMPHOUT,STDOUTPUTHANDLE);
     CLOSE(F^);
     FPCLOSE(TEMPHOUT);
END;

PROCEDURE CambiarEntradaAArchivo(VAR F:TArchivoRedireccion;VAR TempHOut:LONGINT;RUTA:STRING);
BEGIN
     NEW(F);
     ASSIGN(F^,RUTA);
     Reset(F^);
     TEMPHOUT:=FPDUP(STDINPUTHANDLE);
     FPDUP2(FILEREC(F^).HANDLE,STDINPUTHANDLE);
END;

PROCEDURE CambiarEntradaATeclado(VAR F:TArchivoRedireccion;VAR TempHOut:LONGINT);
BEGIN
	 FPDUP2(TEMPHOUT,STDINPUTHANDLE);
     CLOSE(F^);
     FPCLOSE(TEMPHOUT);
END;

END.
