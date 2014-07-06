<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>Ranking</title>
</head>

<body>

por medida de segurança, retirei apenas a visualização, depois será criada a senha para isso.
<table border="0" style="color:#fff;">



<?php

include "connect.php";


$sql = mysql_query("SELECT * FROM ranking");
while ($row = mysql_fetch_assoc($sql)) {
	echo "<tr><td>".$row['id']."</td><td>".$row['email']."</td><td>".$row['minutos'].":".$row['segundos']."</td></tr>";
}





?>
</table>

</body>
</html>