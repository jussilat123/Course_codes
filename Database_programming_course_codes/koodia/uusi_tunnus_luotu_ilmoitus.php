<?php

// luodaan tietokantayhteys ja ilmoitetaan mahdollisesta virheestä

$y_tiedot = "dbname=ryhma6 user=ryhma6 password=Lsjm9cRk4KDHKDKq";

if (!$yhteys = pg_connect($y_tiedot))
   die("Tietokantayhteyden luominen epäonnistui.");

$asiakasid_kysely = "SELECT MAX(Id) from keskustietokanta.Asiakas";
    

$tulos = pg_query($asiakasid_kysely);
$rivi = pg_fetch_array($tulos);
echo "ID on: $rivi[0]";

// jäädään odottamaan käyttäjän syötettä isset-funktiolla, ja kutsutaan lomaketta POST:lla
if (isset($_POST['klikkaus'])){
	header('Location: kirjautuminen.php');
}



pg_close($yhteys);

//Klikkauksesta kirjautumis-sivulle



?>

<html>
 <head>
  <title>Tunnukset luotu onnistuneesti!</title>
 </head>
 <body>

    <!-- Lomake lähetetään samalle sivulle (vrt lomakkeen kutsuminen) -->
    <form action="uusi_tunnus_luotu_ilmoitus.php" method="post">

    <h2>Tunnukset luotu onnistuneesti!</h2>

    <?php if (isset($viesti)) echo '<p style="color:red">'.$viesti.'</p>'; ?>
	

	<!--PHP-ohjelmassa viitataan kenttien nimiin (name) -->
	<table border="0" cellspacing="0" cellpadding="3">
        <tr>
            <td></td>
            <td><input type="submit" name="klikkaus" value="Kirjaudu uudella tunnuksellasi"/></td>
        </tr>
	</table>

	<br />

</body>
</html>