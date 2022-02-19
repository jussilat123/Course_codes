<?php

// luodaan tietokantayhteys ja ilmoitetaan mahdollisesta virheestä

$y_tiedot = "dbname=ryhma6 user=ryhma6 password=Lsjm9cRk4KDHKDKq";

if (!$yhteys = pg_connect($y_tiedot))
   die("Tietokantayhteyden luominen epäonnistui.");
session_start();
// jäädään odottamaan käyttäjän syötettä isset-funktiolla, ja kutsutaan lomaketta POST:lla
if (isset($_POST['ulos'])){
    // jos käyttäjä valitsee uloskirjautumisen, siirrytään kirjautumissivulle
	header('Location: kirjautuminen.php');
}

elseif (isset($_POST['jatka'])) {
    // jos käyttäjä haluaa jatkaa ostoksia, palataan haku-sivulle
    header('Location: haku.php');
}


pg_close($yhteys);


?>

<html>
 <head>
  <title>Tilaus onnistunut!</title>
 </head>
 <body>

    <!-- Lomake lähetetään samalle sivulle (vrt lomakkeen kutsuminen) -->
    <form action="onnistunut_tilaus.php" method="post">

    <h2>Tilaus onnistunut!</h2>

    <?php if (isset($viesti)) echo '<p style="color:red">'.$viesti.'</p>'; ?>
	

	<!--PHP-ohjelmassa viitataan kenttien nimiin (name) -->
	<table border="0" cellspacing="0" cellpadding="3">
        <tr>
            <td>Kiitos tilauksesta, toivottavasti näemme pian uudestaan!</td>
        </tr>
        <tr>
            <td><input type="submit" name="ulos" value="Kirjaudu ulos"/></td>
        </tr>
        <tr>
            <td><input type="submit" name="jatka" value="Jatka ostoksia"/></td>
        </tr>
	</table>

	<br />

</body>
</html>