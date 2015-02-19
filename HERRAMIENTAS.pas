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
UNIT HERRAMIENTAS;

INTERFACE
USES BaseUnix,TDALISTA,TDALISTAPROCESOS,TDALISTAENTRADAS,TDAREGISTROPROCESO,TDALISTAarchivos,VARIABLES;

//CADENAS
FUNCTION EsSubcadena(CADENA:STRING;SUBCADENA:STRING):BOOLEAN;
PROCEDURE BorrarEspacios(VAR CADENA:STRING);
FUNCTION EsInterno(C:String):Boolean;
//RUTAS
FUNCTION RutaPadreValida(RUTA:STRING):BOOLEAN;
PROCEDURE RutaPadre(VAR L:TLISTA);
FUNCTION RutaValida(RUTA:STRING):BOOLEAN;
PROCEDURE PasajeRutaALista(RUTA:STRING;VAR L:TLISTA;SEPARADOR:CHAR);
FUNCTION PasajeListaARuta(L:TLISTA;SEPARADOR:CHAR):STRING;
PROCEDURE ReemplazarRuta(var ruta:string);
//RUTAS ARCHIVOS
FUNCTION RutaValidaArchivo(ruta:string):boolean;
PROCEDURE RutaArchivo(var ruta:string);
//ENTRADAS
PROCEDURE TransformarEntrada(ENTRADA:STRING;VAR L:TLISTA);
FUNCTION NombreEjecucion(ENTRADA:STRING):BOOLEAN;
//ARCHIVOS
PROCEDURE LeerArchivo(RUTAARCHIVO:STRING);
//LS
PROCEDURE ObtenerEntradas(DIRECTORIO:PDIR;VAR LISTAARCHIVOS:TLISTAA);
PROCEDURE ListarLSl(listaArchivos:TLISTAA);
PROCEDURE ListaSinOcultos(VAR L:TLISTAA);
PROCEDURE ListarConColores(L:TLISTAA);
PROCEDURE ListarSinColores(L:TLISTAA);
FUNCTION OpcionLS(ARGUMENTO:STRING):BOOLEAN;
//PROCESOS
FUNCTION PIDProcesoActual(L:TLISTAPROCESO):CARDINAL;
FUNCTION PIDProcesoAnterior(L:TLISTAPROCESO):CARDINAL;
FUNCTION EspNomProcAmb(L:TLISTAPROCESO;Nombre:STRING):BOOLEAN;
FUNCTION BusquedaProcesoNombre(VAR L:TLISTAPROCESO;NOMBRE:STRING):CARDINAL;
FUNCTION BusquedaProcesoPID(VAR L:TLISTAPROCESO;PID:CARDINAL):CARDINAL;
FUNCTION BusquedaProcesoNumTrabajo(VAR L:TLISTAPROCESO;NUMTRABAJO:CARDINAL):CARDINAL;
PROCEDURE AgregarTrabajo(VAR L:TLISTAPROCESO;PID:CARDINAL;NOMBRE:STRING);
PROCEDURE ActualizarOpcionListaProc(VAR L:TLISTAPROCESO);
FUNCTION PIDValido(PID:LONGINT):BOOLEAN;
PROCEDURE ProcesosTerminados(VAR L:TLISTAPROCESO);
PROCEDURE ActualizarListaProcesos(VAR L:TLISTAPROCESO);
PROCEDURE ModificarEstadoOpcionTrabajo(VAR L:TLISTAPROCESO;PID:CARDINAL;ESTADO,OPCION:CHAR);
PROCEDURE EliminarTrabajo(VAR L:TLISTAPROCESO;PID:CARDINAL);
FUNCTION LineaJOBS(P:PROCESO;Opcion:CHAR):STRING;
FUNCTION ObtenerNumTrabajo(CAD:STRING):CARDINAL;
PROCEDURE ListarInfoProceso(L:TLISTAPROCESO;OPCION:CHAR);
FUNCTION PIDAsociadNumTrabajo(L:TLISTAPROCESO;NUM:CARDINAL):LONGINT;
FUNCTION DeterminarPID(L:TLISTAPROCESO;NUM:STRING):LONGINT;
//KILL y SEÑALES
FUNCTION OpcionKill(ARGUMENTO:STRING):BOOLEAN;
FUNCTION TransformarSenial(AUX:STRING):STRING;
FUNCTION EsSenial(AUX:STRING):BOOLEAN;
FUNCTION DevolverSenial(SENIAL:STRING):CINT;
PROCEDURE Mostrar(N1,N2:INTEGER);
//EXTRAS p/ COMANDOS
PROCEDURE EntradaEstandar;
FUNCTION SegundoPlano(L:TLISTA):BOOLEAN;
//LISTA ENTRADAS
PROCEDURE LeerEntrada(VAR L:TLISTAENTRADA;VAR ENT:STRING);
PROCEDURE AgregarAlHistorial(VAR L:TLISTAENTRADA;ENTRADA:STRING;RUTA:STRING);
PROCEDURE CargarListaEntradas(RUTA:STRING;VAR L:TLISTAENTRADA);
//REDIRECCION y TUBERÍAS
PROCEDURE SeparadorSalidaEstandar(VAR L:TLISTA;VAR Resultado:TLISTA;OPCION:CHAR);
FUNCTION EsTuberia(L:TLISTA):BOOLEAN;
FUNCTION EsRedireccionSalidaEstandar(L:TLISTA): BOOLEAN;
PROCEDURE LecturaPipe(VAR L: TLISTA; VAR LE:TLISTAENTRADA;RUTA:STRING);

IMPLEMENTATION
USES Unix, Unixtype, crt, SysUtils,DateUtils,users,unixutil,ARCHIVO,MENSAJE;
//CADENAS
FUNCTION SubCadena(CADENA:STRING; INICIO:INTEGER; FIN:INTEGER):STRING;
BEGIN
     SubCadena:=COPY(CADENA,INICIO,FIN-INICIO);
END;

FUNCTION EsSubcadena(CADENA:STRING;SUBCADENA:STRING):BOOLEAN;
BEGIN
	 EsSubcadena:=POS(SUBCADENA,CADENA)<>0
END;

PROCEDURE BorrarEspacios(VAR CADENA:STRING);
BEGIN
     WHILE ((LENGTH(CADENA)>0) AND (CADENA[1]=' '))DO
           DELETE(CADENA,1,1);
END;

FUNCTION Oculto(X:STRING):BOOLEAN;
BEGIN
	OCULTO:=X[1]='.';
END;

FUNCTION EsInterno(C:String):Boolean;
BEGIN
     EsInterno:=(C='miexit')OR(C='miclear')  OR(C='mils')  OR(C='micd')  OR(C='micat')OR(C='mibg')OR
				(C='mifg')  OR(C='mihistory')OR(C='mijobs')OR(C='mikill')OR(C='mipwd')
END;

//RUTAS
FUNCTION RutaPadreValida(RUTA:STRING):BOOLEAN;
VAR
L:TLISTA;
BEGIN
	 CREARLISTA(L,'');
	 PasajeRutaALista(RUTA,L,'/');
	 RUTAPADRE(L);
	 RUTA:=PasajeListaARuta(L,'/');
	 RutaPadreValida:=RutaValida(RUTA);
END;


PROCEDURE RutaPadre(VAR L:TLISTA);
VAR X:TDATOS;
BEGIN
     EliminarUltimo(L,X);
END;

FUNCTION RutaValida(ruta:string):boolean;
BEGIN
     {$I-}
     ChDir (ruta);
     RutaValida:=IOresult=0;
     {$I+}
END;

FUNCTION PasajeListaARuta(L:TLISTA;SEPARADOR:CHAR):string;
VAR
AUX:TDATOS;
BEGIN
     Primero(L);
     Aux:='/';  
     If(NOT fin(L))then
     Begin
          Aux:=Aux+Info(L)+Separador;
          Siguiente(L);
          While(NOT fin(L))do
          Begin
               Aux:=Aux+Info(L)+Separador;
               Siguiente(L);
          End;
     End;
     IF(length(aux)>1)THEN
        delete(aux,length(aux),length(aux));
     PasajeListaARuta := Aux;
END;

PROCEDURE PasajeRutaALista(RUTA:STRING;VAR L:TLISTA;SEPARADOR:CHAR);
VAR
AUX:INTEGER;
BEGIN
	 DELETE(RUTA,1,1);
     WHILE(RUTA<>'')DO
     BEGIN
          AUX:=POS(SEPARADOR,RUTA);
          IF (AUX = 0)THEN
             AUX:= LENGTH(RUTA)+1;
          INSERTARULTIMO(L,SUBCADENA(RUTA,1,AUX));
          DELETE(RUTA,1,AUX);
     END;
END;

PROCEDURE ReemplazarRuta(VAR RUTA:STRING);
VAR DIRLISTA:TLISTA;
BEGIN
	CREARLISTA(DIRLISTA,'');
	CASE RUTA[1] OF
       '~': RUTA:=HOMEMASUSUARIOACTUAL;    
       '.':  BEGIN
                  IF RUTA[2]='.' THEN
                  BEGIN
                       PASAJERUTAALISTA(DIRE,DIRLISTA,'/');
                       RUTAPADRE(DIRLISTA);
                       RUTA:=PASAJELISTAARUTA(DIRLISTA,'/');
                  END
                  ELSE
                      IF RUTA[2]='/' THEN
			BEGIN
				RUTA:=COPY(RUTA,3,LENGTH(RUTA));
                        	RUTA:=DIRE+'/'+RUTA;
			END
                      ELSE
                          	RUTA:=DIRE;
             END;
       '-': RUTA:=OLDDIR;
       '/': RUTA:=RUTA;
       ELSE
           IF RUTA[1]<>'/' THEN
             IF (DIRE[LENGTH(DIRE)]='/')THEN
                 RUTA:=DIRE+RUTA
             ELSE
				 RUTA:=DIRE+'/'+RUTA;
       END;
END;

//RUTAS ARCHIVOS
FUNCTION RutaValidaArchivo(RUTA:STRING):BOOLEAN;
BEGIN
     RUTAVALIDAARCHIVO:= FPOPEN(RUTA,O_RDONLY)>0;
END;

PROCEDURE RutaArchivo(VAR RUTA:STRING);
BEGIN
	CASE RUTA[1] OF
	'.': BEGIN
		IF RUTA[2]='/' THEN
		BEGIN
			RUTA:=COPY(RUTA,3,LENGTH(RUTA));
                	RUTA:=DIRE+'/'+RUTA;
		END
	     	ELSE
			RUTA:=DIRE+'/'+RUTA;
	     END;
       	ELSE
           IF RUTA[1]<>'/' THEN
               RUTA:=DIRE+'/'+RUTA;
	END;
	
END;


//ENTRADAS
PROCEDURE TransformarEntrada(ENTRADA:STRING;VAR L:TLISTA);
VAR
AUX:STRING;
COMILLAS:BOOLEAN;
BEGIN
     BORRARESPACIOS(ENTRADA);
     AUX:='';
	 WHILE(LENGTH(ENTRADA)>0)DO
	 BEGIN
		  AUX:='';
		  COMILLAS:=FALSE;
		  BORRARESPACIOS(ENTRADA);
		  WHILE ((LENGTH(ENTRADA)>0) AND ((ENTRADA[1]<>' ')OR COMILLAS)) DO
		  BEGIN
			   AUX:=AUX+ENTRADA[1];
			   IF (ENTRADA[1]=#39)THEN
				  COMILLAS:=NOT COMILLAS;
			   DELETE(ENTRADA,1,1);
		  END;
		  IF(AUX<>'')THEN
			  INSERTARULTIMO(L,AUX);
	 END;
END;

FUNCTION NombreEjecucion(ENTRADA:STRING):BOOLEAN;
BEGIN
	 NombreEjecucion:=((ENTRADA[1]='.')AND(ENTRADA[2]='/'))OR(ENTRADA[1]='/')
END;

//ARCHIVOS
FUNCTION GetFilePermissions(mode: mode_t): string; // Recibe un dato de tipo mode_t y devuelve un string que muestra
VAR						    // el tipo y los permisos del archivo para el usuario,el grupo y otros.
Result: string;
BEGIN
	   Result:='';
	   if STAT_IFLNK and mode=STAT_IFLNK then	// file type
	     Result:=Result+'l' //enlace
	   else
	   if STAT_IFDIR and mode=STAT_IFDIR then
	     Result:=Result+'d' //directorio
	   else
	   if STAT_IFBLK and mode=STAT_IFBLK then
	     Result:=Result+'b' //disp de bloque
	   else
	   if STAT_IFCHR and mode=STAT_IFCHR then
	     Result:=Result+'c'	//disp de caracter
	   else
	     Result:=Result+'-';

	   if STAT_IRUSR and mode=STAT_IRUsr then	// user permissions
	     Result:=Result+'r'
	   else
	     Result:=Result+'-';
	   if STAT_IWUsr and mode=STAT_IWUsr then
	     Result:=Result+'w'
	   else
	     Result:=Result+'-';
	   if STAT_IXUsr and mode=STAT_IXUsr then
	     Result:=Result+'x'
	   else
	     Result:=Result+'-';
	
	   if STAT_IRGRP and mode=STAT_IRGRP then	   // group permissions
	     Result:=Result+'r'
	   else
	     Result:=Result+'-';
	   if STAT_IWGRP and mode=STAT_IWGRP then
	     Result:=Result+'w'
	   else
	     Result:=Result+'-';
	   if STAT_IXGRP and mode=STAT_IXGRP then
	     Result:=Result+'x'
	   else
	     Result:=Result+'-';
	   
	   if STAT_IROTH and mode=STAT_IROTH then	// other permissions
	     Result:=Result+'r'
	   else
	     Result:=Result+'-';
	   if STAT_IWOTH and mode=STAT_IWOTH then
	     Result:=Result+'w'
	   else
	     Result:=Result+'-';
	   if STAT_IXOTH and mode=STAT_IXOTH then
	     Result:=Result+'x'
	   else
	     Result:=Result+'-';
	   GetFilePermissions:=Result;
END;

PROCEDURE TipoArchivo(A:STAT;VAR TIPO:CHAR);
BEGIN
	TIPO:='N';
	if (not(fpS_ISDIR(A.st_mode))) and (STAT_IXUsr and A.st_mode=STAT_IXUsr) then
		TIPO:='E' //ejecutables
	else	
	IF fpS_ISLNK(A.st_mode) then
		TIPO:='L' //El archivo es un enlace (link)
	ELSE
	IF fpS_ISREG(A.st_mode) then
		TIPO:='R' //El archivo es un archivo regular o comun
	ELSE
	IF fpS_ISDIR(A.st_mode) then
		TIPO:='D' //El archivo es un directorio
	ELSE
	IF fpS_ISCHR(A.st_mode) then
		TIPO:='C' //El archivo es un dispositivo de carac
	ELSE
	IF fpS_ISBLK(A.st_mode) then
		TIPO:='B' //El archivo es un dispositivo de bloques
	ELSE
	IF fpS_ISFIFO(A.st_mode) then
		TIPO:='P' //El archivo es una cañeria (Pipe)
	ELSE
	IF fpS_ISSOCK(A.st_mode) then
		TIPO:='S'; //El archivo es un socket
END;

PROCEDURE LeerArchivo(RUTAARCHIVO:STRING); //DESDE AFUERA SE LE PASA EL ARCHIVO QUE DEBE ABRIR (CREO QUE COMO UN STRING)!!
VAR FD : LONGINT;
TAM,I: INTEGER;
LECTURA:STRING;
INFO:STAT;
BEGIN	
	IF FPSTAT(RUTAARCHIVO,INFO)=0 THEN
	BEGIN	
		FD := FPOPEN(RUTAARCHIVO,O_RDONLY);
		IF FD > 0 THEN
		BEGIN
			SETLENGTH(LECTURA,INFO.ST_SIZE-1); //CREA UN STRING (LECTURA)CON LA LONGITUD INDICADA (INFO.ST_SIZE)
			TAM:=(INFO.ST_SIZE);  
			I:=1;
			WHILE I<TAM DO
                      	BEGIN
				IF FPREAD(FD,LECTURA[I],1) < 0 THEN
	       	          	BEGIN
	       	            		WRITELN('ERROR CON EL ARCHIVO O DIRECTORIO'); 
	       	          	END; 
				INC(I);
			END;
			WRITE(LECTURA);
			FPCLOSE(FD);
		END;
	END;
END;

//LS
PROCEDURE MOSTRARCOLOR(TIPO:CHAR); //PROBAR
BEGIN
	CASE TIPO OF
		'L':textColor(11); //Cyan claro
		'R':textColor(7); //Black
		'D':textColor(9); //Blue claro
		'C':textColor(14); //Parpadeo
		'B':textColor(14); //Parpadeo
		'P':textColor(14); //Yellow
		'S':textColor(13); //Magenta claro
		'E':textColor(10); //Verde claro
		'X':textColor(12); //gris oscuro
		'N':textColor(7); //de neutro!!
	END;
END;

PROCEDURE ObtenerEntradas(DIRECTORIO:PDIR;VAR LISTAARCHIVOS:TLISTAA);
VAR
ENTRADA: PDIRENT;
RUTAENTRADA:STRING;
ARCHIVO: STAT;
AUX:TDATOSA;
BEGIN
	 REPEAT
	       ENTRADA := FPREADDIR(DIRECTORIO^); //SI EL DIRECTORIO NO SE PUEDE ABRIR DEVUELVE NIL
		   WITH ENTRADA^ DO
           	   BEGIN
	           	IF(ENTRADA <> NIL) THEN
	           	BEGIN
				RUTAENTRADA:=pchar(@d_name[0]); //nombre del directorio entrada
				RUTAARCHIVO(RUTAENTRADA);
                   		IF FPSTAT(RUTAENTRADA,ARCHIVO)=0  THEN //SI EL VALOR NO ES 0,HAY ERROR
		        	BEGIN   
					AUX.CLAVE:=pchar(@d_name[0]);
					AUX.REGSTAT:=ARCHIVO;
					INSERTARULTIMOA(LISTAARCHIVOS,AUX);
				END;
	                END;
		   END;
	  UNTIL ENTRADA = NIL;
END;

PROCEDURE LISTARlsl(listaArchivos:TLISTAA);
VAR D:TDATETIME;
YY,MM,DD,HH,MI,SS,MS: WORD;
PERMISOS,USUARIO,GRUPO,FECHA:STRING;
X:TDATOSA;
TOTAL,TAM,NLINK:CARDINAL;
TIPO:CHAR;
BEGIN
	total:=0;
	WHILE not (TAMANOA(listaArchivos)=0) DO
	BEGIN		
		ELIMINARiPOSA(listaArchivos,X,1);
		permisos:=GetFilePermissions(REGSTAT(X).st_mode);      	// permisos
		nlink:=(REGSTAT(X).st_nlink);        			// links 
		usuario:=GetUserName(REGSTAT(X).st_uid);      		// usuario 
		grupo:=GetGroupName(REGSTAT(X).st_gid);        		// grupo 
		tam:=(REGSTAT(X).st_size);        			// tamanio 
		D:=UnixToDateTime(REGSTAT(X).st_ctime);			// fecha de ultima modificacion
		DecodeDate (D,YY,MM,DD) ;
		DecodeTime (D,HH,MI, SS,MS) ;                            
		fecha:=(meses[MM]+' '+dias[DD]+' '+numero[HH]+':'+numero[MI]); 
		//LISTADO
		MOSTRARCOLOR('N'); 				     
		WRITE(permisos);
		gotoxy(12,WhereY);
		WRITE(nlink);
		gotoxy(14,WhereY);
		WRITE(usuario);
		gotoxy(22,WhereY);
		WRITE(grupo);
		gotoxy(30,WhereY);
		WRITE(tam:9);
		gotoxy(40,WhereY);
		WRITE(fecha);
		gotoxy(54,WhereY);
		TIPOARCHIVO(REGSTAT(X),TIPO);  
		MOSTRARCOLOR(TIPO);		
		WRITELN(CLAVE(X));
		MOSTRARCOLOR('N');				

		total:=total+tam;
	END;
	writeln('Total: ', total);
END;

PROCEDURE ListaSinOcultos(VAR L:TLISTAA);
VAR
X:TDATOSA;
LISTAAUX:TLISTAA;
BEGIN
	CREARLISTAA(LISTAAUX,'');
	WHILE (TAMANOA(L)<>0) DO
	BEGIN
		 ELIMINARULTIMOA(L,X);
		 IF not(OCULTO(CLAVE(X))) THEN
		 BEGIN
	 		 INSERTARiPOSA(LISTAAUX,X,1);
		 END;
	END;
	L:=LISTAAUX;	
END;

PROCEDURE ListarSinColores(L:TLISTAA);
VAR
X:TDATOSA;
BEGIN	
	WHILE NOT(FINA(L))DO
	BEGIN
		 ELIMINARiPOSA(L,X,1);
		 WRITELN(CLAVE(X));
	END;
END;

PROCEDURE ListarConColores(L:TLISTAA);
VAR
X:TDATOSA;
TIPO:CHAR;
BEGIN	
	while not(FINA(L)) do
	begin
		ELIMINARiPOSA(L,X,1);
		TIPOARCHIVO(REGSTAT(X),TIPO);
		MOSTRARCOLOR(TIPO);	
		WRITELN(CLAVE(X));
	end;
	MOSTRARCOLOR('N');
END;

FUNCTION OpcionLS(ARGUMENTO:STRING):BOOLEAN;
BEGIN
	 OpcionLS:=((LENGTH(ARGUMENTO)=2)AND(ARGUMENTO[1]='-')AND(ARGUMENTO[2] IN ['f','l','a']))
END;

//PROCESOS
FUNCTION PIDProcesoActual(L:TLISTAPROCESO):CARDINAL;
BEGIN
     PRIMEROP(L);
     WHILE((NOT FINP(L))AND(OPCION(INFOP(L))<>'+'))DO
        SIGUIENTEP(L);
     PIDPROCESOACTUAL:=DEVOLVERPID(INFOP(L));
END;

FUNCTION PIDProcesoAnterior(L:TLISTAPROCESO):CARDINAL;
BEGIN
     PRIMEROP(L);
     WHILE((NOT FINP(L))AND(OPCION(INFOP(L))<>'-'))DO
        SIGUIENTEP(L);
     PIDPROCESOANTERIOR:=DEVOLVERPID(INFOP(L));
END;

FUNCTION EspNomProcAmb(L:TLISTAPROCESO;NOMBRE:STRING):BOOLEAN;
VAR
I:INTEGER;
BEGIN
	 PRIMEROP(L);
	 I:=0;
	 WHILE((NOT FINP(L))AND(I<2))DO
	 BEGIN
	      IF(POS(NOMBRE,NOMBREPROCESO(INFOP(L)))<>0)THEN
	        INC(I);
	      SIGUIENTEP(L);
	 END;
	 EspNomProcAmb:=(I>=2);
END;

FUNCTION BusquedaProcesoNombre(VAR L:TLISTAPROCESO;NOMBRE:STRING):CARDINAL;
VAR
I:CARDINAL;
BEGIN
     PRIMEROP(L);
     I:=1;
	 WHILE (NOT(FINP(L))AND(POS(NOMBRE,NOMBREPROCESO(INFOP(L)))=0))DO
	 BEGIN
	      SIGUIENTEP(L);
	      INC(I);
	 END;
	 IF FINP(L) THEN
	   I:=0;
	 BusquedaProcesoNombre:=I;  
END;

FUNCTION BusquedaProcesoPID(VAR L:TLISTAPROCESO;PID:CARDINAL):CARDINAL;
VAR
I:CARDINAL;
BEGIN
     PRIMEROP(L);
     I:=1;
	 WHILE ((NOT FINP(L))AND(DEVOLVERPID(INFOP(L))<>PID))DO
	 BEGIN
	      SIGUIENTEP(L);
	      INC(I);
	 END;
	 IF FINP(L) THEN
	   I:=0;
	 BusquedaProcesoPID:=I;    
END;

FUNCTION BusquedaProcesonumTrabajo(VAR L:TLISTAPROCESO;NUMTRABAJO:CARDINAL):CARDINAL;
VAR
I:CARDINAL;
BEGIN
     PRIMEROP(L);
     I:=1;
	 WHILE ((NOT FINP(L))AND (NumeroTrabajo(INFOP(L))<>NUMTRABAJO))DO
	 BEGIN
	      SIGUIENTEP(L);
	      INC(I);
	 END;
	 IF FINP(L) THEN
	   I:=0;
	 BusquedaProcesonumTrabajo:=I;
END;

FUNCTION PIDValido(PID:LONGINT):BOOLEAN;
BEGIN	
	fpKill(PID,0);
  	PIDValido:=fpgeterrno<>3
END;

PROCEDURE ProcesosTerminados(VAR L:TLISTAPROCESO);
VAR
P:TDATOSPROCESO;
BEGIN
	 PRIMEROP(L);
	 WHILE NOT FINP(L) DO
	 BEGIN
		  IF (EstadoProceso(INFOP(L))='E')AND(NOT PIDValido(DevolverPid(INFOP(L))))THEN
		  BEGIN
			   P:=INFOP(L);
			   MODIFP(L,CAMBIARESTADO(P,'H'));
		  END;
		  SIGUIENTEP(L);
	 END;
END;

PROCEDURE ActualizarListaProcesos(VAR L:TLISTAPROCESO);
BEGIN
	 PRIMEROP(L);
	 WHILE NOT FINP(L) DO
	 BEGIN
		  IF (EstadoProceso(INFOP(L))IN ['T','H','I'])THEN
			  ELIMINARTRABAJO(L,DEVOLVERPID(INFOP(L)));
		  SIGUIENTEP(L);
	 END;
END;

PROCEDURE AgregarTrabajo(VAR L:TLISTAPROCESO;PID:CARDINAL;NOMBRE:STRING);
VAR
H:TDATOSPROCESO;
BEGIN
	 ACTUALIZAROPCIONLISTAPROC(L);
	 H:=CrearProceso(PID,TAMANOP(L)+1,NOMBRE,'D','+');
	 INSERTARULTIMOP(L,H);
END;

PROCEDURE ActualizarOpcionListaProc(VAR L:TLISTAPROCESO);
VAR
P:TDATOSPROCESO;
BEGIN
	 PRIMEROP(L);
	 WHILE((NOT FINP(L))AND(Opcion(INFOP(L))='-'))DO
	    SIGUIENTEP(L);
	 IF (NOT FINP(L)) THEN
	 BEGIN
	      P:=INFOP(L);
	      P:=CAMBIAROPCION(P,' ');
	      ModifP(L,P);
	 END;
	 WHILE((NOT FINP(L))AND(Opcion(INFOP(L))='+'))DO
	    SIGUIENTEP(L);
	 IF (NOT FINP(L)) THEN
	 BEGIN
	      P:=INFOP(L);
	      P:=CAMBIAROPCION(P,'-');
	      ModifP(L,P);
	 END;
END;

PROCEDURE ModificarEstadoOpcionTrabajo(VAR L:TLISTAPROCESO;PID:CARDINAL;ESTADO,OPCION:CHAR);
VAR
POSICION:LONGINT;
X:TDATOSPROCESO;
BEGIN
	 POSICION:=BUSQUEDAPROCESOPID(L,PID);
	 IF POSICION<>0 THEN
	 BEGIN
	      ELIMINARiPOSP(L,X,POSICION);
	      X:=CAMBIARESTADO(X,ESTADO);
	      X:=CAMBIAROPCION(X,OPCION);
	      INSERTARiPOSP(L,X,POSICION);
	 END;
END;

PROCEDURE EliminarTrabajo(VAR L:TLISTAPROCESO;PID:CARDINAL);
VAR
POSICION:CARDINAL;
X:TDATOSPROCESO;
BEGIN
     POSICION:=BUSQUEDAPROCESOPID(L,PID);
	 IF POSICION<>0 THEN
	    ELIMINARiPOSP(L,X,POSICION);
END;

FUNCTION LineaJOBSPIDOptionL(P:PROCESO):STRING;
VAR
LINEA:STRING;
BEGIN
     LINEA:='['+IntToStr(NumeroTrabajo(P))+']';
	 IF((OPCION(P)='+') OR (OPCION(P)='-'))THEN
	     LINEA:=LINEA+OPCION(P)+'  '
	 ELSE 
		 LINEA:=LINEA+'   ';
     LINEA:=LINEA+IntToStr(DevolverPid(P))+' ';
	 CASE EstadoProceso(P) OF
     'E':LINEA:=LINEA+'Ejecutando              '+NombreProceso(P)+' &';
	 'D':LINEA:=LINEA+'Parado                  '+NombreProceso(P);
	 'T':LINEA:=LINEA+'Terminado (killed)      '+NombreProceso(P);
	 'F':LINEA:=LINEA+'Terminado               '+NombreProceso(P);
	 'H':LINEA:=LINEA+'Hecho                   '+NombreProceso(P);
	 'I':LINEA:=LINEA+'Interrupción            '+NombreProceso(P);
	 END;
	 LineaJOBSPIDOptionL:=LINEA;
END;

FUNCTION LineaJOBSPID(P:PROCESO):STRING;
VAR
LINEA:STRING;
BEGIN
     LINEA:='['+IntToStr(NumeroTrabajo(P))+']';
	 IF((OPCION(P)='+') OR (OPCION(P)='-'))THEN
	     LINEA:=LINEA+OPCION(P)+'  '
	 ELSE 
		 LINEA:=LINEA+'   ';
	 CASE EstadoProceso(P) OF
     'E':LINEA:=LINEA+'Ejecutando              '+NombreProceso(P)+' &';
	 'D':LINEA:=LINEA+'Detenido                '+NombreProceso(P);
	 'T':LINEA:=LINEA+'Terminado (killed)      '+NombreProceso(P);
	 END;
	 LineaJOBSPID:=LINEA;
END;

FUNCTION LineaJOBS(P:PROCESO;Opcion:CHAR):STRING;
BEGIN
	 IF((Opcion=#0)OR(Opcion='s'))THEN
	     LineaJOBS:=LineaJOBSPID(P)
	 ELSE
	 BEGIN
		  IF(Opcion='l')THEN
		      LineaJOBS:=LineaJOBSPIDOptionL(P)
		  ELSE
			  LineaJOBS:=IntToStr(DEVOLVERPID(P));
     END
END;

FUNCTION ObtenerNumTrabajo(CAD:STRING):CARDINAL;
VAR
NUM:CARDINAL;
CODE:WORD;
BEGIN
	 IF(CAD[1]='%')THEN
	   DELETE(CAD,1,1);
	 VAL(CAD,NUM,CODE);
	 IF(CODE=0)THEN
	     ObtenerNumTrabajo:=NUM
	 ELSE
		 ObtenerNumTrabajo:=0; 
END;

PROCEDURE ListarInfoProceso(L:TLISTAPROCESO;Opcion:CHAR);
BEGIN
	 PRIMEROP(L);
     WHILE NOT(FINP(L)) DO
     BEGIN
		  WRITELN(LineaJOBS(INFOP(L),Opcion));
	      SIGUIENTEP(L);
     END
END;

FUNCTION PIDAsociadNumTrabajo(L:TLISTAPROCESO;NUM:CARDINAL):LONGINT;
BEGIN
	 PrimeroP(L);
	 WHILE((NOT FinP(L))AND(NumeroTrabajo(InfoP(L))<>NUM))DO
		SiguienteP(L);
	 IF NOT FinP(L) THEN
	     PIDAsociadNumTrabajo:=DevolverPid(InfoP(L))
	 ELSE
		 PIDAsociadNumTrabajo:=0;
END;

FUNCTION DeterminarPID(L:TLISTAPROCESO;NUM:STRING):LONGINT;
VAR
CODE:WORD;
I:CARDINAL;
BEGIN
	 IF(NUM[1]='%')THEN
	 BEGIN
		  VAL(COPY(NUM,2,LENGTH(NUM)),I,CODE);
		  IF(CODE=0)THEN
		      DeterminarPID:=PIDAsociadNumTrabajo(L,I)
		  ELSE
			  DeterminarPID:=0
	 END
	 ELSE
	 BEGIN
		  VAL(NUM,I,CODE);
		  IF(CODE=0)THEN
		     DeterminarPID:=I
	      ELSE
			  DeterminarPID:=0
	 END;
END;

//KILL y SEÑALES
FUNCTION OpcionKill(ARGUMENTO:STRING):BOOLEAN;
VAR
OP1,OP2:BOOLEAN;
BEGIN
	 OP1:=(LENGTH(ARGUMENTO)=2)AND(ARGUMENTO[2] IN ['l','s','n']);
	 OP2:=(ARGUMENTO[1]='-')AND EsSenial(COPY(ARGUMENTO,2,LENGTH(ARGUMENTO)));
	 OpcionKill:=OP1 OR OP2
END; 

FUNCTION EsSenial(AUX:STRING):BOOLEAN;
VAR
I:CARDINAL;
CODE:WORD;
BEGIN
	 VAL(AUX,I,CODE);
	 IF CODE<>0 THEN
		 EsSenial:=(DevolverSenial(AUX)<>0)
	 ELSE
		 EsSenial:=(I<31)AND(I>=0)
END;

FUNCTION TransformarSenial(AUX:STRING):STRING;
CONST
TablaKill:ARRAY [1..30] OF STRING =('SIGHUP','SIGINT','SIGQUIT','SIGILL','SIGTRAP',
		'SIGABRT','SIGBUS','SIGFPE','SIGKILL','SIGUSR1','SIGSEGV','SIGUSR2','SIGPIPE',
		'SIGALRM','SIGTERM','SIGSTKFLT','SIGCHLD','SIGCONT','SIGSTOP','SIGTSTP','SIGTTIN',
		'SIGTTOU','SIGURG','SIGXCPU','SIGXFSZ','SIGALRM','SIGPROF','SIGWINCH','SIGIO','SIGPWR');
VAR
I:CARDINAL;
CODE:WORD;
BEGIN
	 VAL(AUX,I,CODE);
	 IF((CODE<>0)AND(I=0))THEN
	     TransformarSenial:='T'
	 ELSE
	 BEGIN
		  IF CODE<>0 THEN
			  TransformarSenial:=IntToStr(DevolverSenial(AUX))
		  ELSE
			  TransformarSenial:=COPY(TablaKill[I],4,length(TablaKill[I]));
     END;
END;

FUNCTION DevolverSenial(SENIAL:STRING):CINT;
CONST
TablaKill:ARRAY [1..30] OF STRING =('SIGHUP','SIGINT','SIGQUIT','SIGILL','SIGTRAP',
		'SIGABRT','SIGBUS','SIGFPE','SIGKILL','SIGUSR1','SIGSEGV','SIGUSR2','SIGPIPE',
		'SIGALRM','SIGTERM','SIGSTKFLT','SIGCHLD','SIGCONT','SIGSTOP','SIGTSTP','SIGTTIN',
		'SIGTTOU','SIGURG','SIGXCPU','SIGXFSZ','SIGALRM','SIGPROF','SIGWINCH','SIGIO','SIGPWR');
VAR
I:INTEGER;
A:STRING;
CODE:WORD;
BEGIN
	 VAL(SENIAL,I,CODE);
	 IF (CODE=0)THEN
	 BEGIN
	      IF((I>0)AND(I<31))THEN
	          DevolverSenial:=I
	      ELSE
		      DevolverSenial:=-1;
	 END
	 ELSE
	 BEGIN
		  A:=UPPERCASE(SENIAL);
		  I:=1;
		  WHILE((I<31)AND(TablaKill[I]<>A)AND(POS(A,TablaKill[I])<>4))DO
		     INC(I);
		  IF(I<31)THEN
		      DevolverSenial:=I
		  ELSE
			  DevolverSenial:=-1;
	END;
END;

PROCEDURE Mostrar(N1,N2:INTEGER);
CONST
TablaKill:ARRAY [1..30] OF STRING =('SIGHUP','SIGINT','SIGQUIT','SIGILL','SIGTRAP',
		'SIGABRT','SIGBUS','SIGFPE','SIGKILL','SIGUSR1','SIGSEGV','SIGUSR2','SIGPIPE',
		'SIGALRM','SIGTERM','SIGSTKFLT','SIGCHLD','SIGCONT','SIGSTOP','SIGTSTP','SIGTTIN',
		'SIGTTOU','SIGURG','SIGXCPU','SIGXFSZ','SIGALRM','SIGPROF','SIGWINCH','SIGIO','SIGPWR');
VAR
I,COL:INTEGER;
BEGIN
	 COL:=0;
     I:=1;
     REPEAT
		   IF(I<10)THEN 
		       GOTOXY(COL*N2+2,WHEREY)
		   ELSE
			   GOTOXY(COL*N2+1,WHEREY);
		   WRITE(I,')',TablaKill[I]);
		   INC(I);
		   INC(COL);
		   IF(COL>=N1)THEN
		   BEGIN
		        COL:=0;
			    GOTOXY(1,WHEREY+1);
		   END;     
     UNTIL(I=31)
END;

//EXTRAS p/ COMANDOS
PROCEDURE EntradaEstandar;
VAR 
TECLA:CHAR;
TEXTO:STRING;
ESCRITO:BOOLEAN;
BEGIN
	TECLA:=READKEY;
	TEXTO:='';
	WHILE (TECLA <>#4) DO	
	BEGIN
		ESCRITO:=TRUE;
		WRITE(TECLA);
		IF (TECLA =#13) THEN
		BEGIN
			WRITELN;
			WRITELN(TEXTO);
			TEXTO:='';
			TECLA:=#0;
			ESCRITO:=FALSE;	
		END;	
		TEXTO:=TEXTO+TECLA;
		TECLA:= READKEY;
		IF (TECLA=#4)AND ESCRITO THEN
		BEGIN
			WRITE(TEXTO);
			TEXTO:='';
			TECLA:=READKEY;
		END;
	END;
END;

FUNCTION SegundoPlano(L:TLISTA):BOOLEAN;
VAR
AUX:BOOLEAN;
BEGIN
     PRIMERO(L);
     AUX:=FALSE;
     WHILE((NOT FIN(L))AND(NOT AUX))DO
     BEGIN
		  AUX:=POS('&',INFO(L))<>0;
		  SIGUIENTE(L);
     END;
     SegundoPlano:=AUX;
END;

//LISTA ENTRADAS
FUNCTION Espacios(N:CARDINAL):STRING;
VAR
AUX:STRING;
I:CARDINAL;
BEGIN
     AUX:='';
     FOR I:=1 TO N DO
       AUX:=' '+AUX;
     Espacios:=AUX;
END;

PROCEDURE IZQUIERDA(VAR CADENA:STRING;VAR POS:INTEGER);
BEGIN
	 IF((CADENA<>'')AND(POS>1))THEN
	 BEGIN
		  DEC(POS);
		  GOTOXY(WHEREX-1,WHEREY);
	 END;
END;

PROCEDURE DERECHA(VAR CADENA:STRING;VAR POS:INTEGER);
BEGIN
	 IF((CADENA<>'')AND(POS<LENGTH(CADENA)+1))THEN
	 BEGIN
		  INC(POS);
		  GOTOXY(WHEREX+1,WHEREY);
	 END;
END;

PROCEDURE ABAJO(VAR L:TLISTAENTRADA;VAR CADENA:STRING;PosIX:INTEGER;VAR I,F:BOOLEAN);
BEGIN
	 Gotoxy(PosIX,wherey);
	 WRITE(Espacios(length(cadena)+1));
	 Gotoxy(PosIX,wherey);
	 IF NOT(TamanoE(L)=0) THEN
	 BEGIN
		 IF NOT F THEN
		 BEGIN
			 IF I THEN
			 BEGIN
			      PrimeroE(L);
			      I:=FALSE;
			      CADENA:=InfoE(L);
			 END
			 ELSE
			 BEGIN
				  IF (SigIsNil(L)OR FinE(L))THEN
			      BEGIN
			           F:=TRUE;
			           CADENA:='';
			      END
			      ELSE
				  BEGIN
					   SiguienteE(L);
					   CADENA:=InfoE(L);
				  END
			 END; 
		 END
     END
     ELSE
		 CADENA:='';
	 WRITE(CADENA);
END;

PROCEDURE ARRIBA(VAR L:TLISTAENTRADA;VAR CADENA:STRING;PosIX:INTEGER;VAR I,F:BOOLEAN);
BEGIN
	 Gotoxy(PosIX,wherey);
	 WRITE(Espacios(length(cadena)+1));
	 Gotoxy(PosIX,wherey);
	 IF NOT(TamanoE(L)=0) THEN
	 BEGIN
		 IF NOT I THEN
		 BEGIN
			 IF F THEN
			 BEGIN
			      UltimoE(L);
			      F:=FALSE;
			      CADENA:=InfoE(L);
			 END
			 ELSE
			 BEGIN
				  IF (AntIsNil(L)OR InicioE(L))THEN
			      BEGIN
			           I:=TRUE;
			           CADENA:='';
			      END
			      ELSE
				  BEGIN
					   AnteriorE(L);
					   CADENA:=InfoE(L);
				  END
			 END; 
		 END
     END
     ELSE
		 CADENA:='';
	 WRITE(CADENA);
END;

PROCEDURE Insertar(VAR CADENA:STRING;Caracter:CHAR;VAR POS:INTEGER);
VAR
PRI,CAD:STRING;
X:INTEGER;
BEGIN
	 PRI:=Copy(CADENA,1,POS-1);
	 CAD:=Copy(CADENA,POS,LENGTH(CADENA));
	 X:=WHEREX;
	 Write(Caracter,CAD);
	 GOTOXY(X+1,WHEREY);
	 INC(POS);
	 CADENA:=PRI+CARACTER+CAD
END;

PROCEDURE Eliminar(VAR CADENA:STRING;VAR POS:INTEGER;PosIX:INTEGER);
VAR
X:INTEGER;
BEGIN
	 IF(POS>1)THEN
	 BEGIN
	 	  DELETE(CADENA,POS-1,1);
		  X:=WHEREX;
		  GOTOXY(PosIX,WHEREY);
		  WRITE(Espacios(length(CADENA)+3));
		  DEC(POS);
		  GOTOXY(PosIX,WHEREY);
		  WRITE(CADENA);
		  GOTOXY(X-1,WHEREY);
	 END;
END;

PROCEDURE LeerEntrada(VAR L:TLISTAENTRADA;VAR ENT:STRING);
VAR
PosIX:INTEGER; //Posición Inicial X
AUX:STRING;
Caracter:CHAR;
POS:INTEGER;
INI,FIN:BOOLEAN;
BEGIN
	 INI:=FALSE;
	 FIN:=TRUE;
     PosIX:=wherex;
     AUX:='';
     POS:=1;
     REPEAT
           Caracter:=ReadKey;
           CASE Caracter OF
	           #0:BEGIN
					   Caracter:=ReadKey;
					   CASE Caracter OF
		                   #75:IZQUIERDA(AUX,POS);	    //Izquierda
		                   #77:DERECHA(AUX,POS);  	    //Derecha
		                   #80:BEGIN				//Abajo
									ABAJO(L,AUX,PosIX,INI,FIN);
									POS:=LENGTH(AUX)+1;
							   END;
		                   #72:BEGIN				//Arriba
									ARRIBA(L,AUX,PosIX,INI,FIN);
									POS:=LENGTH(AUX)+1;
							   END;
					   END;
				  END;
			   #13:WRITELN;
			   #8:Eliminar(AUX,POS,PosIX);
			   ELSE
			   BEGIN
				    If((ORD(Caracter)>31)OR(ORD(Caracter)=3))THEN
				       Insertar(AUX,Caracter,POS);
			   END;
		  END;     
     UNTIL(CARACTER=#13);  //ENTER
     ENT:=AUX;
END;

PROCEDURE AgregarAlHistorial(VAR L:TLISTAENTRADA;ENTRADA:STRING;RUTA:STRING);
BEGIN
	 AgregarEntrada(L,ENTRADA);
	 EscribirStringArchivo(RUTA,ENTRADA);
END;

PROCEDURE CargarListaEntradas(RUTA:STRING;VAR L:TLISTAENTRADA);
VAR
ENTRADA:ARRAYCHAR;
I:CARDINAL;
AUX:STRING;
BEGIN
	 CREARLISTAE(L,'');
	 IF (TamanoArchivo(RUTA)>0)THEN
	 BEGIN
		  LeerArchivoADAT(RUTA,ENTRADA);
		  I:=2;{Al principio se guarda #13}
		  REPEAT
			    AUX:='';
			    WHILE ((HIGH(ENTRADA)+1>I)AND(ENTRADA[I]<>#10))DO
			    BEGIN
			         AUX:=AUX+ENTRADA[I];
			         INC(I);
			    END;
			    AgregarEntrada(L,AUX);
			    INC(I);
		  UNTIL(HIGH(ENTRADA)+1<=I);
	 END
END;

//REDIRECCION y TUBERÍAS
PROCEDURE SeparadorSalidaEstandar(VAR L:TLISTA;VAR Resultado:TLISTA;OPCION:CHAR);
VAR			
COMANDO:TLISTA;
BEGIN
	 CASE OPCION OF
		 '1':OPCION:='>';
		 '2':OPCION:='|';
	 END;
	 CREARLISTA(Resultado,'');
	 CREARLISTA(COMANDO,'');
	 PRIMERO(L);
	 WHILE (NOT FIN(L))AND(INFO(L)[1]<>OPCION)DO
	 BEGIN
		 InsertarUltimo(COMANDO,INFO(L));
		 SIGUIENTE(L);
	 END;
	 IF(NOT FIN(L))AND(INFO(L)[1]='|')THEN
	     SIGUIENTE(L);
	 WHILE (NOT FIN(L)) DO
	 BEGIN
		 INSERTARULTIMO(Resultado,INFO(L));
		 SIGUIENTE(L);
	 END;
	 CERRARLISTA(L,'');
	 L:=COMANDO;	 
END;

FUNCTION EsTuberia(L:TLISTA):BOOLEAN;
BEGIN
	 PRIMERO(L);
	 WHILE (NOT FIN(L))AND(POS('|',INFO(L))=0)DO
	     SIGUIENTE(L);
	 EsTuberia:=(NOT FIN(L))
END;

FUNCTION EsRedireccionSalidaEstandar(L:TLISTA):BOOLEAN;
BEGIN
	 PRIMERO(L);
	 WHILE (NOT FIN(L))AND(POS('>',INFO(L))=0)AND(POS('>>',INFO(L))=0) DO
	     SIGUIENTE(L);
	 EsRedireccionSalidaEstandar:=(NOT FIN(L))
END;

PROCEDURE LecturaPipe(VAR L: TLISTA; VAR LE:TLISTAENTRADA;RUTA:STRING);
VAR
E:TDATOSENTRADA;
LISTA:TLISTA;
BEGIN
	 PRIMERO(L);
	 WHILE(NOT NodoFinal(L))DO 
	    SIGUIENTE(L);
	 WHILE((INFO(L)='|')AND NodoFinal(L))DO
	 BEGIN
		  CREARLISTA(LISTA,'');
		  WRITE('>');
		  LEERENTRADA(LE,E);
		  IF(E<>'')THEN
		  BEGIN
			   TRANSFORMARENTRADA(E,LISTA);
			   CONCATENARLISTAS(L,LISTA);
		  END;
		  WHILE(NOT NodoFinal(L))DO
			  SIGUIENTE(L);
	 END; 
	 AGREGARALHISTORIAL(LE,ListaAString(L),RUTA);	
END;

END.
