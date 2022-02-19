<?php

// luodaan tietokantayhteys ja ilmoitetaan mahdollisesta virheestä

$y_tiedot = "dbname=ryhma6 user=ryhma6 password=Lsjm9cRk4KDHKDKq";

if (!$yhteys = pg_connect($y_tiedot))
   die("Tietokantayhteyden luominen epäonnistui.");

$luokkien_hinta_kysely = "SELECT keskustietokanta.Teos.Luokka AS Luokka, SUM(keskustietokanta.Nide.Hinta) AS Kokonaishinta, ROUND(SUM(keskustietokanta.Nide.Hinta)/COUNT(*), 2) AS Keskihinta
FROM keskustietokanta.Teos, keskustietokanta.Nide
WHERE keskustietokanta.Teos.Id = keskustietokanta.Nide.Teos_id
GROUP BY keskustietokanta.Teos.Luokka";
    

$tulos = pg_query($luokkien_hinta_kysely);
$tulosTaulu = pg_fetch_all($tulos);
echo '<table>
        <tr>
         <td>Luokka</td>
         <td>Kokonaishinta</td>
         <td>Keskihinta</td>
        </tr>';
foreach($tulosTaulu as $taulu)
{
    echo '<tr>
            <td>'. $taulu['luokka'].'</td>
            <td>'. $taulu['kokonaishinta'].'</td>
            <td>'. $taulu['keskihinta'].'</td>
          </tr>';
}
echo '</table>';


pg_close($yhteys);


?>

<html>
 <head>
  <title>Toka raportti</title>
 </head>
 <body>


    <h2></h2>

    <?php if (isset($viesti)) echo '<p style="color:red">'.$viesti.'</p>'; ?>
	

	<!--PHP-ohjelmassa viitataan kenttien nimiin (name) -->
	<table border="0" cellspacing="0" cellpadding="3">
        <tr>
            <td></td>
        </tr>
	</table>

	<br />

</body>
</html>