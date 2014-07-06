<?

if(!($id = mysql_connect("localhost", "harrisq6_masuser", "n021pass"))) {
   echo "Não foi possível estabelecer uma conexão com o gerenciador MySQL. Favor Contactar o Administrador.";
   exit;
}
if(!($con=mysql_select_db("harrisq6_n021mas",$id))) {
   echo "Não foi possível estabelecer uma conexão com o gerenciador MySQL. Favor Contactar o Administrador.";
   exit;
}
?>