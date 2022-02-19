<?php

// luodaan tietokantayhteys ja ilmoitetaan mahdollisesta virheestä

$y_tiedot = "dbname=ryhma6 user=ryhma6 password=Lsjm9cRk4KDHKDKq";

if (!$yhteys = pg_connect($y_tiedot))
   die("Tietokantayhteyden luominen epäonnistui.");

$kysely = "SELECT keskustietokanta.Asiakas.Nimi AS Nimi, COUNT(*) AS Kpl
FROM keskustietokanta.Asiakas, keskustietokanta.Ostanut, keskustietokanta.Tilaus
WHERE keskustietokanta.Asiakas.Id = keskustietokanta.Ostanut.Id AND keskustietokanta.Ostanut.Tilaus_id=keskustietokanta.Tilaus.Tilaus_id
 AND keskustietokanta.Tilaus.Myyntipaivamaara > (CURRENT_DATE - INTERVAL '12 months')
GROUP BY keskustietokanta.Asiakas.Nimi";
    

$tulos = pg_query($kysely);
$tulosTaulu = pg_fetch_all($tulos);
echo '<table>
        <tr>
         <td>Nimi;Kpl</td>
        </tr>';
foreach($tulosTaulu as $taulu)
{
    echo '<tr>
            <td>'. $taulu['nimi'].';'. $taulu['kpl'].'</td>
          </tr>';
}
echo '</table>';


pg_close($yhteys);


?>

<html>
 <head>
  <title>Kolmas raportti</title>
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