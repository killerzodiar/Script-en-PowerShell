#Menu de configuracion de red:
#Definicion de funciones:
function get-menu
{
  $respuesta = Read-Host "`n` Elige una opcion `n` 1: Obtener informacion de los adaptadores `n` 2: Configurar ip estatica `n` 3: Configurar ip dinamica `n` 4: Salir `n` Opcion "
switch ($respuesta){
    '1' {Gip}
    '2' {ip-fija}
    '3' {ip-dhcp}
    '4' {
    Clear-Host
    Write-Host "adios"
      exit}
    default {Write-Host "Opcion no valida" }}  
}

function ip-fija
{
   get-interface
   #Introducimos los nuevos datos:
   $ip = Read-Host "Dime la ip que vas a introducir"
   $longitud = Read-Host "Longitud de la mascara"
   $gateway = Read-Host "Dime la puerta de enlace"
   $dns1 = Read-Host "Dime el primer dns que vas a introducir"
   $dns2 = Read-Host "Dime el segundo dns que vas a introducir"
   #Establecemos los nuevos datos introducidos:
   New-NetIPAddress -InterfaceIndex $interface -IPAddress $ip -PrefixLength $longitud -DefaultGateway $gateway
   Set-DnsClientServerAddress -InterfaceIndex $interface -ServerAddresses ("$dns1","$dns2")
   Restaurar-red
}

function ip-dhcp
{   
    get-interface
   #Establecemos los nuevos datos introducidos:  
    Set-NetIPInterface –InterfaceIndex $interface –Dhcp enable
    Set-DnsClientServerAddress –InterfaceIndex $interface -ResetServerAddresses
    Restaurar-red
}

function Restaurar-red {
    #Añadido en caso de fallo para restaurar los adaptadores:
    gip -InterfaceIndex $interface |Select-Object InterfaceAlias >inter.tmp
    cat .\inter.tmp -Last 3 >inter2.tmp
    $nombre = cat .\inter2.tmp -First 1
    Remove-Item -Confirm:$false inter.tmp
    Remove-Item -Confirm:$false inter2.tmp
    $nombre = $nombre.Trim() #Trim borra los espacios en blanco restantes
    Restart-NetAdapter -Name "$nombre"

}

function get-interface
{
    $script:interface = Read-Host "Dime el indexf de la interfaz que vas a utilizar para dhcp" 
    #Añadimos $script:"nombre de la variable" para definirla a nuivel del script ya que si no se borra al termianr la funcion
    #Borramos los datos anteriores:
    Remove-NetIPAddress -InterfaceIndex $interface -Confirm:$false
	Remove-NetRoute -InterfaceIndex $interface -Confirm:$false
}



#Bucle de repeticion para el menu:
do{
    Get-menu
    $intro = Read-Host "Pulsa intro para continuar"
}while ($true)
