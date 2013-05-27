<?php
$db = new mysqli('localhost', 'user', 'password', 'database');
/*
CREATE TABLE `scores` (
	`id` int(11) NOT NULL AUTO_INCREMENT,
	`date` datetime NOT NULL,
	`name` varchar(12) COLLATE utf8_unicode_ci NOT NULL,
	`score` int(10) unsigned NOT NULL,
	`hits` int(10) unsigned NOT NULL,
	`fails` int(10) unsigned NOT NULL,
	`spree` int(10) unsigned NOT NULL,
	`time` double unsigned NOT NULL,
	PRIMARY KEY (`id`)
)
 */

if($_SERVER['REQUEST_METHOD'] == "POST"){
	if($qry = $db->prepare("INSERT INTO `scores` (date, name, score, hits, fails, spree, time) VALUES (NOW(), ?, ?, ?, ?, ?, ?)")){
		if(isset($_POST['name'])
		&& isset($_POST['score'])
		&& isset($_POST['hits'])
		&& isset($_POST['fails'])
		&& isset($_POST['spree'])
		&& isset($_POST['time'])){
			$qry->bind_param("ssssss",
				$_POST['name'],
				$_POST['score'],
				$_POST['hits'],
				$_POST['fails'],
				$_POST['spree'],
				$_POST['time']);
			$qry->execute();
			$qry->close();
		}
	}
}

if($_SERVER['REQUEST_METHOD'] == "GET"){
?>
<!doctype html>
<html>
	<head>
		<title>TippTippReloaded Highscores</title>
		<meta charset="utf-8">
	</head>
	<body>
		<h1><a href="https://ps0ke.de/code/tipptippreloaded/">TippTippReloaded</a> Highscores</h1>
		<table>
			<thead>
				<tr>
					<th>Rank</th>
					<th>Score</th>
					<th>Name</th>
				</tr>
			</thead>
			<tbody>
<?php
	$highscores = $db->query("SELECT s.name, MAX(score) as score, (SELECT s2.date as date FROM scores s2 WHERE s.name = s2.name ORDER by s2.score DESC LIMIT 1) as date FROM scores s GROUP BY s.name ORDER by score DESC LIMIT 10");
	$rank = 1;
	while($score = $highscores->fetch_assoc()){
		echo "\t\t\t\t<tr title=\"".htmlspecialchars($score['date'])."\">\n\t\t\t\t\t<td>$rank</td>\n";
		echo "\t\t\t\t\t<td>".htmlspecialchars($score['score'])."</td>\n";
		echo "\t\t\t\t\t<td>".htmlspecialchars($score['name'])."</td>\n\t\t\t\t</tr>\n";
		$rank++;
	}
?>
			</tbody>
		</table>
	</body>
</html>
<?php
}
?>

