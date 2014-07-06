<?php

//include "connect.php";


//mysql_query("INSERT INTO ranking (email, minutos, segundos) VALUES ('".$_GET['email']."', '".$_GET['minutos']."', '".$_GET['segundos']."')");




$mensagem = "E-mail: ".$_GET['email']." fez no tempo: ".$_GET['minutos'].':'.$_GET['segundos'];

//mail("mister.ndesign@gmail.com", "[CADASTRO] O que é o N 021", $mensagem, "From: oqueeon021@oqueeon021.com.br");
mail("h@harrison.com.br", "[CADASTRO] O que é o N 021", $mensagem, "From: oqueeon021@oqueeon021.com.br");
//mail("oqueeon021@oqueeon021.com.br", "[CADASTRO] O que é o N 021", $mensagem, "From: oqueeon021@oqueeon021.com.br");




?>