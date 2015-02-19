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
UNIT COMANDOS;
{$mode objfpc}
INTERFACE
USES TDALISTAPROCESOS,TDALISTAENTRADAS,TDALISTA;

//COMANDOS
PROCEDURE PROMPT;
//PROCEDIMIENTOS
PROCEDURE InternoOExterno(AUXILIAR:TLISTA;VAR ListaProcesos:TLISTAPROCESO;VAR ListaEntradas:TLISTAENTRADA;OPCION,RUTA:STRING); //EstdSal indica si se ha cambiado o no la salida estandar
PROCEDURE EjecutarRedireccionSalidaEstandar(L:TLISTA;VAR ListaProc:TLISTAPROCESO;VAR LISTAENTRADAS:TLISTAENTRADA);  
PROCEDURE EjecutarPipe(L: TLISTA;VAR ListaProc:TLISTAPROCESO;VAR LISTAENTRADAS:TLISTAENTRADA);  

IMPLEMENTATION
USES HERRAMIENTAS,ARCHIVO,TDALISTAARCHIVOS,VARIABLES,BASEUNIX, UNIX, UNIXTYPE, CRT,SYSUTILS,TDAREGISTROPROCESO;

PROCEDURE Espera(VAR L:TLISTAPROCESO;PID:LONGINT);FORWARD;
//SIGNAL HANDLER
PROCEDURE FinalHijo(SINGAL:LONGINT);cdecl;
BEGIN
	 FinHijo:=TRUE;
END;      

//COMANDOS
PROCEDURE PROMPT;  // muestra en pantalla el prompt
BEGIN
      WRITE(USUARIOACTUAL,'@',HOSTACTUAL,':');                                       //USUARIO@ -MÁQUINA:
      IF COPY(DIRE,1,LENGTH(HOMEMASUSUARIOACTUAL)) = HOMEMASUSUARIOACTUAL THEN
         WRITE('~',COPY(DIRE,LENGTH(HOMEMASUSUARIOACTUAL)+1,LENGTH(DIRE)))                  //USUARIO@ -MÁQUINA:~
      ELSE
          WRITE(DIRE);                                                                       //USUARIO@ -MÁQUINA: HOME/USUARIOACTUAL
      IF (USUARIOACTUAL = 'root') THEN
         WRITE('# ')
      ELSE
          WRITE('$ ');
END;

PROCEDURE CD(RUTA:STRING);  // PASADO CAMBIA EL VALOR DE LA VAR GLOBAL DIRE(DIRECTORIO DE TRABAJO ACTUAL)SEGUN EL STRING(RUTA)QUE SE LE PASA
BEGIN
     IF RUTA='' THEN
        RUTA:=HOMEMASUSUARIOACTUAL
     ELSE
     	REEMPLAZARRUTA(RUTA);
     IF RUTAVALIDA(RUTA)THEN
     BEGIN
          OLDDIR:=DIRE;
          DIRE:=RUTA;
     END
     ELSE
		  WRITELN('micd ', RUTA, ': No existe el archivo o el directorio');
END;

FUNCTION PWD:STRING;
BEGIN
	 PWD:=DIRE;
END;

PROCEDURE CAT(LISTAARCHIVOS: TLISTA); //CADA NODO DE LA LISTA TIENE UNA RUTA A UN ARCHIVO QUE DEBE LEER
VAR RUTA:STRING;		//CUANDO SE LLAMA A ESTA FUNCION, QUE LA LISTAARCHIVOS NO TENGA EL PRIMER NODO CON EL MICAT.
BEGIN	
	IF TAMANO(LISTAARCHIVOS)=0 THEN
		ENTRADAESTANDAR;		
	PRIMERO(LISTAARCHIVOS);
	WHILE NOT(FIN(LISTAARCHIVOS)) DO
	BEGIN
		RUTA:=INFO(LISTAARCHIVOS);		
		RUTAARCHIVO(RUTA);
		IF RUTAVALIDAARCHIVO(RUTA) THEN
			LEERARCHIVO(RUTA)
		ELSE
			WRITELN('micat ',RUTA ,': No existe el archivo o el directorio');
		SIGUIENTE(LISTAARCHIVOS);
	END;
END;

PROCEDURE LS(ARGUMENTO:STRING;RUTA:STRING);  //NUEVO //procedimiento reemplazarRuta(ruta) va antes de llamar al ls. Si no se le pasa ninguna ruta se asume el directorio actual de trabajo.
VAR
DIRECTORIO: Pdir;
listaArchivos:TLISTAA;
BEGIN
	CREARLISTAA(listaArchivos,'');
	Directorio := fpOpenDir(RUTA); //donde Directorio  es un puntero a un registro que es el directorio
	If (Directorio<>NIL) then
	Begin
	 	olddir:=dire;
		dire:=RUTA;
	 	If ARGUMENTO='' THEN //ls común   tendría que ser ''
	 	Begin			
			ObtenerEntradas(Directorio,listaArchivos);
			ListaSinOcultos(listaArchivos);
			ORDENARLISTA(listaArchivos);
	  		ListarConColores(listaArchivos);
		End
		Else
			Case ARGUMENTO[2] of
				'f':begin //ls -f
					ObtenerEntradas(Directorio,listaArchivos);
					LISTARSINCOLORES(listaArchivos);
				  end;
				'a':begin //ls -a
					ObtenerEntradas(Directorio,listaArchivos);
					ORDENARLISTA(listaArchivos);
	  				ListarConColores(listaArchivos);
				  end;
				'l':begin //ls -l
					ObtenerEntradas(Directorio,listaArchivos);
					ListaSinOcultos(listaArchivos);
					ORDENARLISTA(listaArchivos);
					LISTARlsl(listaArchivos);
				  end;	
			end;
	  	WRITELN('Cantidad de archivos: ', TAMANOA(listaArchivos));
		fpCloseDir (Directorio^);
     	End
	Else
		writeln('Error en la lectura del directorio');
	dire:=olddir;
END;

PROCEDURE KILL (senial:CINT;PID:LONGINT); //kill que envia señal a un proceso
VAR
ERROR:LONGINT;
BEGIN	
	Try fpKill(PID,senial);
  	except On E : EConvertError do
	Writeln ('Error en los parametros');
  	end;
  	ERROR:=fpgeterrno;
  	IF ERROR=3 THEN   {sys_esrch}
  	     WRITELN('bash: mikill: (',PID,') - No existe el proceso');
END;

PROCEDURE BG(PID:LONGINT);
BEGIN
	 KILL(SIGCONT,PID);
END;

PROCEDURE EJEC(PID:LONGINT;VAR L:TLISTAPROCESO;TIPO:STRING);
BEGIN
	 FinHijo:=FALSE;
	 ModificarEstadoOpcionTrabajo(L,PID,'E','+');
	 ActualizarOpcionListaProc(L);
	 BG(PID);
	 IF TIPO='mifg'then
	  ESPERA(L,PID);
END;

PROCEDURE EJECUCION (ARGUMENTO: STRING;VAR L:TLISTAPROCESO;TIPO:STRING);
VAR
NUM:CARDINAL;
NOM:STRING;
AUX:BOOLEAN;
CODE:WORD;
BEGIN
	 AUX:=FALSE;
	 IF(TAMANOP(L)=0)THEN
	   WRITELN(TIPO,': actual: no existe ese trabajo')
	 ELSE
	 BEGIN
	      PRIMEROP(L);
	      CASE ARGUMENTO[1] OF
	       #0:BEGIN
				WHILE(OPCION(INFOP(L))<>'+')DO
		           SIGUIENTEP(L);
		        EJEC(DEVOLVERPID(INFOP(L)),L,TIPO);
		        AUX:=TRUE;
		   END;
		   '1'..'9':BEGIN
						 VAL(ARGUMENTO,NUM,CODE);
						 IF CODE=0 THEN
						 BEGIN
							 IF(BusquedaProcesoPID(L,NUM)<>0)THEN
							 BEGIN
							 	  EJEC(NUM,L,TIPO);
							  	  AUX := TRUE;
							 END
					     END
					 END;
		   '+':BEGIN
					IF(LENGTH(ARGUMENTO)=1)THEN
					BEGIN
						 EJEC(PIDPROCESOACTUAL(L),L,TIPO);
						 AUX:=TRUE;
				    END
				    ELSE
					BEGIN
						 WRITELN('bash: mifg: ',ARGUMENTO,': opción inválida');
						 WRITELN('mifg: uso: fg [id_trabajo]');
					END
			   END;
		   '-':BEGIN
					IF(LENGTH(ARGUMENTO)=1)THEN
					BEGIN
						 EJEC(PIDPROCESOANTERIOR(L),L,TIPO);
						 AUX:=TRUE;
				    END
				    ELSE
					BEGIN
						 WRITELN('bash: mifg: ',ARGUMENTO,': opción inválida');
						 WRITELN('mifg: uso: fg [id_trabajo]');
					END
			   END;
		   '?':BEGIN
					NOM:=COPY(ARGUMENTO,2,LENGTH(ARGUMENTO));
					IF NOT(EspNomProcAmb(L,NOM)) THEN
					BEGIN
					     IF (BUSQUEDAPROCESONOMBRE(L,NOM)<>0)THEN
						 BEGIN
						      EJEC(DEVOLVERPID(INFOP(L)),L,TIPO);
							  AUX := TRUE;
						 END
					END
					ELSE
					    WRITELN('bash: ',TIPO,': ',NOM,': especificación de trabajo ambigua');
			   END;
		   '%':BEGIN
					IF(ARGUMENTO[2] IN ['0'..'9'])THEN
					BEGIN
					     VAL(COPY(ARGUMENTO,2,LENGTH(ARGUMENTO)),NUM,CODE);
					     IF CODE=0 THEN
					     BEGIN
						      IF (BUSQUEDAPROCESONUMTRABAJO(L,NUM)<>0)THEN
							  BEGIN
							       EJEC(DEVOLVERPID(INFOP(L)),L,TIPO);
								   AUX := TRUE;
							  END
						 END
					END
					ELSE
					BEGIN
						 IF((LENGTH(ARGUMENTO)=1)OR(ARGUMENTO[2]='+')OR(ARGUMENTO[2]='%'))THEN
						 BEGIN
						      EJEC(PIDPROCESOACTUAL(L),L,TIPO);
						      AUX:=TRUE;
						 END
						 ELSE
						     IF(ARGUMENTO[2]='-')THEN
						     BEGIN
						          EJEC(PIDPROCESOANTERIOR(L),L,TIPO);
						          AUX:=TRUE;
							 END
							 ELSE
							 BEGIN
								  IF(NOT(ARGUMENTO[2]=#63))THEN
									 BEGIN
										  NOM:=COPY(ARGUMENTO,2,LENGTH(ARGUMENTO));
										  IF (BUSQUEDAPROCESONOMBRE(L,NOM)<>0)THEN
										  BEGIN
											   EJEC(DEVOLVERPID(INFOP(L)),L,TIPO);
										       AUX := TRUE;
										  END
									 END
									 ELSE
									 BEGIN
										  NOM:=COPY(ARGUMENTO,3,LENGTH(ARGUMENTO));
										  IF NOT(EspNomProcAmb(L,NOM)) THEN
										  BEGIN
										       IF (BUSQUEDAPROCESONOMBRE(L,NOM)<>0)THEN
											   BEGIN
											        EJEC(DEVOLVERPID(INFOP(L)),L,TIPO);
										    		AUX:=TRUE;
											   END
										  END
										  ELSE
										      WRITELN('bash: ',TIPO,': ',NOM,': especificación de trabajo ambigua');
									 END;		  
							    END;
			   END;
		   END;
		   'A'..'Z','a'..'z','.':
		       BEGIN
					IF NOT(EspNomProcAmb(L,ARGUMENTO)) THEN
					BEGIN
					     IF (BUSQUEDAPROCESONOMBRE(L,ARGUMENTO)<>0)THEN
						 BEGIN
						      EJEC(DEVOLVERPID(INFOP(L)),L,TIPO);
							  AUX := TRUE;
						 END
					END
					ELSE
					    WRITELN('bash: ',TIPO,': ',ARGUMENTO,': especificación de trabajo ambigua');
		       END;
		   END;
		   IF AUX THEN
		   BEGIN
		        IF (TIPO='mibg') THEN
				    ModificarEstadoOpcionTrabajo(L,DEVOLVERPID(INFOP(L)),'E','+')
		   END
		   ELSE
			   WRITELN(TIPO,': ',ARGUMENTO,': no existe ese trabajo');
	 end;
END;

PROCEDURE JOBS(L:TLISTA;ListaProc:TLISTAPROCESO;OPCION:CHAR);
VAR
AUX:STRING;
NUM:LONGINT;
BEGIN
	 IF((Tamano(L)=1)OR((OPCION<>#0)AND(Tamano(L)=2)))THEN
          listarInfoProceso(ListaProc,OPCION)
	 ELSE
	 BEGIN
	 	  IF(OPCION<>#0)THEN
		      SIGUIENTE(L);
		  WHILE (NOT FIN(L)) DO
		  BEGIN
			   AUX:=INFO(L);
			   NUM:=ObtenerNumTrabajo(AUX);
			   IF (NUM>0)AND(NUM<=TamanoP(ListaProc)) THEN
			       WRITELN(LineaJOBS(BusqNT(ListaProc,BusquedaProcesoNumTrabajo(ListaProc,NUM)),OPCION))
			   ELSE
			 	   WRITELN('bash: mijobs: ',AUX,': no existe ese trabajo');
			   siguiente(L);
		  END;
	 END;
END;

PROCEDURE EnviarSenial(L:TLISTA;VAR ListaProc:TLISTAPROCESO;SENIAL:CINT);
VAR
NUM:CARDINAL;
BEGIN
	 SIGUIENTE(L);
	 WHILE NOT(FIN(L))DO
	 BEGIN
		  NUM:=DeterminarPID(ListaProc,INFO(L));
		  IF NUM=0 THEN
		  BEGIN
			   IF NOT(INFO(L)[1]='%')THEN
			       WRITELN('bash: mikill: ',INFO(L),': los argumentos deben ser procesos o IDs de trabajos')
			   ELSE
				   WRITELN('bash: kill: ',INFO(L),': no existe ese trabajo');
		  END
		  ELSE
			  BEGIN
			       KILL(SENIAL,NUM);
			       CASE SENIAL OF
				   2..9,11,13,15,16,23..30:EliminarTrabajo(ListaProc,NUM);
				   1,19..22:BEGIN
								 ModificarEstadoOpcionTrabajo(ListaProc,NUM,'D','+');
								 ActualizarOpcionListaProc(ListaProc);
							END; 
				   END;
			  END;
		  SIGUIENTE(L);
	 END;
END;

PROCEDURE KillArgumento(L:TLISTA;ListaProc:TLISTAPROCESO;AUX:CHAR);
VAR
CAD:STRING;
Signal:CINT;
BEGIN
	 CASE AUX OF
	 'l': IF(TAMANO(L)>2)THEN
		  BEGIN
			   SIGUIENTE(L);
			   WHILE NOT FIN(L) DO
			   BEGIN
					CAD:=INFO(L);
					IF EsSenial(CAD)THEN
					    WRITELN(TransformarSenial(CAD))
					ELSE
						WRITELN('bash: mikill: ',CAD,': especificación de señal inválida');
					SIGUIENTE(L);
			   END;
		  END
		  ELSE
			  Mostrar(5,16);
	 's','n':BEGIN
			  IF(TAMANO(L)>2)THEN
			  BEGIN
				   SIGUIENTE(L);
				   IF(TAMANO(L)>3)THEN
				   BEGIN
						Signal:=DevolverSenial(Info(L));
						IF EsSenial(IntToStr(Signal))THEN
						    EnviarSenial(L,ListaProc,Signal)
						ELSE
							WRITELN('bash: mikill: ',INFO(L),': especificación de señal inválida');
				   END
				   ELSE
					   WRITELN('mikill: uso: mikill [-s señal | -n señal | -señal] pid | idtrabajo ... ó mikill -l [señal]');
			  END
			  ELSE
				  WRITELN('bash: mikill: -s: la opción requiere un argumento');
		 END;
	 #0:EnviarSenial(L,ListaProc,9);
	 END	
END;

//EXTRAS LS
PROCEDURE LsConRuta(L:TLISTA;OPCION:STRING);
VAR
AUX2,AUX3:TDATOS;
MultiplesRutas:BOOLEAN;
CANT:Integer;
BEGIN
	 PRIMERO(L);
	 SIGUIENTE(L);
	 Cant:=2;
	 MultiplesRutas:=FALSE;
	 IF NOT(OPCION='')AND(TAMANO(L)>2)THEN
	 BEGIN
	      SIGUIENTE(L);
	      INC(CANT);
	 END;
	 IF(TAMANO(L)>CANT)THEN					     //Más de 1 RUTA
		  MultiplesRutas:=TRUE; 
	 WHILE(NOT FIN(L))DO
	 BEGIN
	      AUX2:= INFO(L);
		  AUX3:=AUX2;
	      REEMPLAZARRUTA(AUX2);
	      IF RUTAVALIDA(AUX2) THEN
	      BEGIN
	           IF MULTIPLESRUTAS THEN
		           WRITELN(AUX3,':');
		       LS(OPCION,AUX2);
	  	       WRITELN;
		  END
		  ELSE
		      WRITELN('mils: no se puede acceder a ',AUX3,': No existe el archivo o el directorio');
	      SIGUIENTE(L);										     
	 END;
END;

// ESTADO SHELL
PROCEDURE Espera(VAR L:TLISTAPROCESO;PID:LONGINT);
VAR
CARACTER:STRING;
BEGIN
     CARACTER:='';
     TERMINO:=FALSE;
     REPEAT
		   WHILE NOT(KEYPRESSED OR FinHijo) DO
		   BEGIN END;
		   IF NOT FinHijo THEN
		      CARACTER:=READKEY;
	 UNTIL ((CARACTER=#26)OR(CARACTER=#3)OR FinHijo);
	 IF NOT FinHijo THEN
	 BEGIN   
	     IF(CARACTER=#26)THEN
	     BEGIN
	          KILL(SIGSTOP,PID);
	          Termino:=TRUE;
	          ModificarEstadoOpcionTrabajo(L,PID,'D','+');
	          writeln;
	          WRITELN('^Z');
	          WRITELN(LineaJOBS(En(L,TAMANOP(L)),#0));
	     END
	     ELSE
	     BEGIN
	    	  KILL(SIGINT,PID);
	          Termino:=TRUE;
		      EliminarTrabajo(L,PID);
	          writeln;
	          WRITELN('^C');
	     END;
	     WRITELN;
	 END;
	 IF NOT Termino THEN
	 BEGIN
	      WAITPROCESS(0);
	      writeln;
	 END;
	 ProcesosTerminados(ListaProcesos);
	 ActualizarListaProcesos(ListaProcesos);
END;


//    PRINCIPAL -- PRINCIPAL
             //INTERNOS
PROCEDURE EjecutarInterno(L:TLISTA;VAR ListaProc:TLISTAPROCESO;LE:TLISTAENTRADA;OPCION,RUTA:STRING);
VAR
AUX:TDATOS;
ERROR:BOOLEAN;
TempHIn,TempHOut:LONGINT;
F:TArchivoRedireccion;
BEGIN
	 IF (OPCION<>'') THEN
     BEGIN
	      CASE OPCION[1] OF
			  '1':CambiarEntradaAArchivo(F,TempHIn,RUTA);
			  '2':CambiarSalidaAArchivo(F,TempHOut,OPCION[2],RUTA);
			  '3':BEGIN
				       CambiarEntradaAArchivo(F,TempHIn,RUTA);
				       CambiarSalidaAArchivo(F,TempHOut,OPCION[2],RUTA);
			      END;
		 END;
	 END;
     PRIMERO(L);
     AUX:=INFO(L);
     CASE AUX[3] OF
     'b':Begin
			  IF TAMANO(L)=1 THEN
			       IF TAMANOP(LISTAPROC)=0 then
				       WRITELN('bash: mibg: actual: no existe ese trabajo')
				   ELSE
				       EJECUCION(#0,LISTAPROC,'mibg')
			  ELSE
				  Begin
					   SIGUIENTE(L);
					   AUX:= INFO(L);
					   IF TAMANOP(ListaProc)=0 then
					       WRITELN('bash: mibg: ',AUX,': no existe ese trabajo')
					   ELSE
						   EJECUCION(AUX,ListaProc,'mibg');
				   end;
			  end;
     'c':Begin
		      IF(AUX='micd')THEN
		      Begin
				   IF TAMANO(L)=1 THEN
				      CD('')
				   ELSE
					   Begin
							SIGUIENTE(L);
							AUX:=INFO(L);
							CD(AUX);
					   end;
		      end
		      ELSE
				  IF(AUX='miclear')THEN
				     clrscr
				  ELSE
				  Begin
				       ELIMINARiPOS(L,AUX,1);
				       CAT(L);
				  end;
		 end;
     'e':;	
     'f':Begin
			  IF TAMANO(L)=1 THEN
			       IF TAMANOP(ListaProc)=0 then
				       WRITELN('bash: mifg: actual: no existe ese trabajo')
				   ELSE
				       EJECUCION(#0,ListaProc,'mifg')
			  ELSE
				  Begin
					   SIGUIENTE(L);
					   AUX:= INFO(L);
					   IF TAMANOP(ListaProc)=0 then
					       WRITELN('bash: mifg: ',AUX,': no existe ese trabajo')
					   ELSE
						   EJECUCION(AUX,ListaProc,'mifg');
				   end;
			  end;
     'h':ListarEntradas(LE);
     'j':Begin
			  IF (Tamano(L)=1) THEN
			     jobs(L,ListaProc,#0)
			  ELSE
				  Begin
					   SIGUIENTE(L);
					   AUX:=INFO(L);
					   IF (AUX[1] IN ['-','%']) THEN
					   Begin
						   CASE AUX[2] OF
							   'p','s','l':jobs(L,ListaProc,AUX[2]);
							   '1'..'9':jobs(L,ListaProc,#0);
							   ELSE
							   Begin
									IF(AUX='%')THEN
										WRITELN('bash: mijobs: ',AUX,': no existe ese trabajo')
									ELSE
									Begin
										 WRITELN('bash: mijobs: ',AUX,': opción inválida');
										 WRITELN('mijobs: uso: mijobs [-lps] [idtrabajo ...] ');
									end
							   end
						   end
					   end
				  end
	     end;
     'k':Begin
			  IF(TAMANO(L)>1)THEN   							
			  Begin
				   SIGUIENTE(L);
		  		   AUX:=INFO(L);
		  		   IF AUX[1]='-' THEN								
		  		   Begin
			   		   IF OpcionKill(AUX) THEN
			       		   KillArgumento(L,ListaProc,AUX[2])
			   		   ELSE
				   		   WRITELN('bash: mikill: ',COPY(AUX,2,LENGTH(AUX)),': especificación de señal inválida')
	      		   end
	      		   ELSE
			  		   KillArgumento(L,ListaProc,#0);
     		   end
     		   ELSE												
	     		   WRITELN('mikill: uso: mikill [-s señal | -n señal | -señal] pid | idtrabajo ... ó mikill -l [señal]'); 
		 end;
     'l':Begin
			   ERROR:=FALSE;
			   IF(TAMANO(L)>1)THEN   							//ls con opción y/o ruta
			   Begin
					SIGUIENTE(L);
					AUX:=INFO(L);
					IF AUX[1]='-' THEN								//ls con Opción
					Begin
						 IF (NOT OpcionLS(AUX)) THEN
						 Begin
							  WRITELN('mils: opción incorrecta -- «',aux,'»');
							  ERROR:=TRUE;
						 end
				    end
				    ELSE
				        AUX:='';
				    IF NOT ERROR THEN
				    BEGIN
					    IF(TAMANO(L)>2)OR((TAMANO(L)=2)AND(AUX='')) THEN	   //ls con RUTA
						   LsConRuta(L,AUX)
						ELSE											//ls sin RUTA con Opción
							IF OpcionLS(INFO(L))THEN
						        Ls(AUX,PWD)
						    ELSE
								WRITELN('mils: no se puede acceder a ',INFO(L),': No existe el archivo o el directorio');
					END;
			   end
			   ELSE												//ls
				   ls('',pwd);
		 end;
     'p':WRITELN(pwd);
     END;
     IF (OPCION<>'') THEN
     BEGIN
	      CASE OPCION[1] OF
			  '1':CambiarEntradaATeclado(F,TempHIn);
			  '2':CambiarSalidaAPantalla(F,TempHOut);
			  '3':BEGIN
				     CambiarEntradaATeclado(F,TempHIn);
				     CambiarSalidaAPantalla(F,TempHOut);
			      END;
		 END;
	 END     
END;

             //EXTERNOS           
PROCEDURE EjecutarExterno(L:TLISTA;VAR ListaProc:TLISTAPROCESO;OPCION,RUTA:STRING);
VAR
PID:LONGINT;
AUX,AUX2:STRING;
TempHIn,TempHOut:LONGINT;
F:TArchivoRedireccion;
BEGIN
	 PRIMERO(L);
	 FinHijo:=FALSE;
	 AUX:=INFO(L);
	 Termino:=FALSE;
	 RutaArchivo(AUX);
	 IF RutaValidaArchivo(AUX) THEN
	 Begin
		  AUX2:='';		  
          IF(TAMANO(L)>1)THEN
          BEGIN
			   SIGUIENTE(L);
			   AUX2:=INFO(L);
		  END;
		  pid:=fpFork();
		  CASE PID OF
		  -1:Writeln('ERROR CREACIÓN PROCESO');
		   0:BEGIN
				  IF (OPCION<>'') THEN
				  BEGIN
					   CASE OPCION[1] OF
						   '1':CambiarEntradaAArchivo(F,TempHIn,RUTA);
						   '2':CambiarSalidaAArchivo(F,TempHOut,OPCION[2],RUTA);
						   '3':BEGIN
								    CambiarEntradaAArchivo(F,TempHIn,RUTA);
								    CambiarSalidaAArchivo(F,TempHOut,OPCION[2],RUTA);
						       END;
					  END;
				  END; 
				  FpExecLP(AUX,[AUX2]);
			 END;
		  ELSE
			  BEGIN
				   FinHijo:=FALSE;
				   FPSIGNAL(SIGCHLD,@FinalHijo);			   
				   AGREGARTRABAJO(ListaProc,PID,INFO(L));
				   IF SegundoPlano(L) THEN
				   BEGIN
						IF(BusquedaProcesoPID(ListaProc,PID)<>0)THEN
						   WRITELN('[',NumeroTrabajo(INFOP(ListaProc)),'] ',PID);	
				   END
				   ELSE
				       Espera(ListaProc,PID);  
			  END;
		  END;
	 end
	 ELSE
	     WRITELN('bash: ',AUX,': No existe el archivo o el directorio');
END;


// PROCEDIMIENTOS
PROCEDURE InternoOExterno(AUXILIAR:TLISTA;VAR ListaProcesos:TLISTAPROCESO;VAR ListaEntradas:TLISTAENTRADA;OPCION,RUTA:STRING);
VAR
ENTRADA:STRING;
BEGIN
	 PRIMERO(AUXILIAR);
	 ENTRADA:=INFO(AUXILIAR);
	 IF EsInterno(ENTRADA) THEN
		EJECUTARINTERNO(AUXILIAR,ListaProcesos,ListaEntradas,OPCION,RUTA)
	 ELSE
		 IF NombreEjecucion(ENTRADA)THEN
	        EJECUTAREXTERNO(AUXILIAR,ListaProcesos,OPCION,RUTA)
	     ELSE
			 WRITELN(Entrada,': no se encontró la orden')
END;

PROCEDURE EjecutarRedireccionSalidaEstandar(L:TLISTA;VAR ListaProc:TLISTAPROCESO;VAR LISTAENTRADAS:TLISTAENTRADA);  
VAR
AUX:TDATOS;
ListaArchivos:TLISTA;
RUTA:STRING;
ARCHIVO:FILE OF CHAR;
OPCION:CHAR;
BEGIN
	 SEPARADORSALIDAESTANDAR(L,ListaArchivos,'1');
	 PRIMERO(ListaArchivos);
	 WHILE NOT FIN(ListaArchivos) DO
	 BEGIN
		  AUX:=INFO(ListaArchivos);
		  IF ((AUX='>>')OR(AUX='>'))AND(NOT NodoFinal(ListaArchivos)) THEN
		  BEGIN
		   	   SIGUIENTE(ListaArchivos);
		   	   RUTA:=INFO(ListaArchivos);
		   	   RutaArchivo(RUTA);
		   	   IF RutaPadreValida(RUTA) THEN
			   BEGIN
					IF AUX='>' THEN
					BEGIN
						 ASSIGN(ARCHIVO,RUTA);
						 REWRITE(ARCHIVO)
					END;
			   END
			   ELSE
			       WRITELN('bash:',RUTA,': No existe el archivo o el directorio');
		  END;
		  IF (AUX='>>')AND(AUX='>')AND NodoFinal(ListaArchivos) THEN
		     WRITELN('bash: error sintáctico cerca del elemento inesperado newline');
		  SIGUIENTE(ListaArchivos);
	 END;
	 IF(AUX='>>')THEN
		 OPCION:='2'
	 ELSE
		 IF(AUX='>')THEN
		    OPCION:='1';
	 IF (OPCION IN ['1','2'])AND(RutaPadreValida(RUTA))THEN
	    INTERNOoEXTERNO(L,ListaProc,LISTAENTRADAS,'2'+OPCION,RUTA)
END;

PROCEDURE EjecutarPipe(L: TLISTA;VAR ListaProc:TLISTAPROCESO;VAR LISTAENTRADAS:TLISTAENTRADA);
VAR
RESTO:TLISTA;
RUTAARCHIVO,OPCION:STRING;
SALIR,UltimoCiclo,PrimerCiclo:BOOLEAN;
BEGIN
	 RUTAARCHIVO:=homeMasUsuarioActual+'/Tuberias';
	 SALIR:=FALSE;
	 SeparadorSalidaEstandar(L,RESTO,'2');
	 PrimerCiclo:=TRUE;
	 UltimoCiclo:=FALSE;
	 WHILE NOT(((TAMANO(RESTO)=0)AND NOT UltimoCiclo)OR SALIR)DO
	 BEGIN
		  IF EsRedireccionSalidaEstandar(L)THEN
		  BEGIN
			   EjecutarRedireccionSalidaEstandar(L,ListaProc,LISTAENTRADAS);
			   SALIR:=TRUE;
		  END
		  ELSE
		  BEGIN
			   OPCION:='3'+'1';
			   IF PrimerCiclo THEN
			       OPCION:='2'+'1'
			   ELSE IF (TAMANO(RESTO)=0) THEN
			       OPCION:='1'+'1';
			   INTERNOoEXTERNO(L,ListaProc,LISTAENTRADAS,OPCION,RUTAARCHIVO);
			   CERRARLISTA(L,'');
			   CREARLISTA(L,'');
			   L:=RESTO;
			   SeparadorSalidaEstandar(L,RESTO,'2');
			   IF (TAMANO(RESTO)=0)AND(NOT SALIR)THEN
			       UltimoCiclo:=NOT UltimoCiclo;
			   PrimerCiclo:=FALSE;
		  END;
	 END;
END;

END.
