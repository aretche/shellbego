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
UNIT VARIABLES;
INTERFACE
USES BaseUnix,Unix,MENSAJE,TDALISTA,TDALISTAPROCESOS,TDALISTAENTRADAS;

CONST
meses: array[1..12] of string=('ene','feb','mar','abr','may','jun','jul','ago','sep','oct','nov','dic');
dias: array[1..31] of string=(' 1',' 2',' 3',' 4',' 5',' 6',' 7',' 8',' 9','10','11','12','13','14','15','16','17','18','19','20', 						'21','22','23','24','25','26','27','28','29','30','31');    
numero: array[1..60] of string=('01','02','03','04','05','06','07','08','09','10','11','12','13','14','15','16','17','18','19','20', 			         			'21','22','23','24','25','26','27','28','29','30','31','32','33','34','35','36','37','38','39','40',
								'41','42','43','44','45','46','47','48','49','50','51','52','53','54','55','56','57','58','59','60');
VAR
UsuarioActual,HostActual,Dire,OldDir,Home,HomeMasUsuarioActual,Entrada,Ruta:STRING;
Dat:ARRAYCHAR;
Auxiliar:TLISTA;
ListaProcesos:TLISTAPROCESO;
ListaEntradas:TLISTAENTRADA;
PID:LONGINT;
FinHijo,Termino,Redireccion:BOOLEAN;

//PROCEDUREs & FUNCTIONs
PROCEDURE InicializarVariables;

IMPLEMENTATION
USES ARCHIVO;

PROCEDURE InicializarVariables;
BEGIN
     home:='/home';
     olddir:=home;
     usuarioActual:=fpgetenv('USER');
     hostActual:=gethostname;
     homeMasUsuarioActual:=(home+'/'+usuarioActual);
     dire:=homeMasUsuarioActual;
	 CREARLISTAP(ListaProcesos,'');
	 CREARLISTA(Auxiliar,'');
	 CREARLISTAE(ListaEntradas,'');
	 Ruta:=homeMasUsuarioActual+'/Historial';
	 IF(TamanoArchivo(RUTA)=0)THEN
	    CrearArchivo(RUTA);
END;

END.
