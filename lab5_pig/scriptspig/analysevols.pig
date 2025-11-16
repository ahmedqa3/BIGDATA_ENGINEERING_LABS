Flights = LOAD '/user/root/input/shared_volume/test.csv' USING PigStorage(',') AS (
    Year: int, Month: int, DayofMonth: int, DayOfWeek: int, 
    DepTime: chararray, CRSDepTime: chararray, ArrTime: chararray, CRSArrTime: chararray, 
    UniqueCarrier: chararray, FlightNum: int, TailNum: chararray, 
    ActualElapsedTime: int, CRSElapsedTime: int, AirTime: int, 
    ArrDelay: int, DepDelay: int, Origin: chararray, Dest: chararray, 
    Distance: int, Taxiln: int, TaxiOut: int, 
    Cancelled: int, CancellationCode: chararray, Diverted: int, 
    CarrierDelay: int, WeatherDelay: int, NASDelay: int, 
    SecurityDelay: int, LateAircraftDelay: int
);

-- Filtrer les vols valides (non annulés et non détournés)
ValidFlights = FILTER Flights BY (Cancelled == 0 AND Diverted == 0);

Airports = LOAD '/user/root/input/shared_volume/airports.csv' USING PigStorage(',') 
           AS (iata: chararray, airport: chararray, city: chararray, state: chararray, country: chararray, lat: float, long: float);
           
Carriers = LOAD '/user/root/input/shared_volume/carriers.csv' USING PigStorage(',') 
           AS (Code: chararray, Description: chararray);



1--1. Calculer le volume total (Union des départs et des arrivées)
Departures = FOREACH ValidFlights GENERATE Origin AS Airport;
Arrivals = FOREACH ValidFlights GENERATE Dest AS Airport;
AllFlights = UNION Departures, Arrivals;

VolumeByAirport = GROUP AllFlights BY Airport;
TotalVolume = FOREACH VolumeByAirport GENERATE 
              group AS Airport, 
              COUNT(AllFlights) AS TotalFlights;

SortedVolume = ORDER TotalVolume BY TotalFlights DESC;
Top20Airports = LIMIT SortedVolume 20;

DUMP Top20Airports;

-- Compter les vols sortants (Origin)
Outbound = GROUP ValidFlights BY Origin;
CountOut = FOREACH Outbound GENERATE group AS Airport, COUNT(ValidFlights) AS OutboundCount;

-- Compter les vols entrants (Dest)
Inbound = GROUP ValidFlights BY Dest;
CountIn = FOREACH Inbound GENERATE group AS Airport, COUNT(ValidFlights) AS InboundCount;

-- Joindre les comptes (FULL OUTER pour inclure les aéroports qui n'ont que des départs/arrivées)
AirportTotals = JOIN CountOut BY Airport FULL OUTER, CountIn BY Airport;

-- Générer le rapport final
AirportReport = FOREACH AirportTotals GENERATE
                  (CountOut::Airport IS NULL ? CountIn::Airport : CountOut::Airport) AS Airport_Code,
                  (OutboundCount IS NULL ? 0 : OutboundCount) AS Sortants,
                  (InboundCount IS NULL ? 0 : InboundCount) AS Entrants,
                  (long)( (OutboundCount IS NULL ? 0 : OutboundCount) + (InboundCount IS NULL ? 0 : InboundCount) ) AS Total;

DUMP AirportReport;

2-- 1. Compter le volume total par transporteur (UniqueCarrier) et par Année
CarrierVolume_Group = GROUP ValidFlights BY (UniqueCarrier, Year);
CarrierVolume = FOREACH CarrierVolume_Group GENERATE
                group.UniqueCarrier AS Carrier,
                group.Year AS Year,
                COUNT(ValidFlights) AS TotalFlights;

-- 2. Calculer le volume Logarithmique (Log base 10)
CarrierLogVolume = FOREACH CarrierVolume GENERATE
                   Carrier,
                   Year,
                   LOG10(TotalFlights) AS LogVolume;

-- 3. Grouper par Transporteur pour simuler la médiane (classement basé sur la Moyenne, car MEDIAN n'est pas native)
CarrierAvgLogVolume = GROUP CarrierLogVolume BY Carrier;
AvgLogVolume = FOREACH CarrierAvgLogVolume GENERATE
               group AS Carrier,
               AVG(CarrierLogVolume.LogVolume) AS AvgLogVolume;

-- 4. Classer les transporteurs par leur volume log moyen (proxy pour la médiane)
RankedCarriers = ORDER AvgLogVolume BY AvgLogVolume DESC;

DUMP RankedCarriers;

3 -- Préparer la relation avec le marqueur de retard et l'heure de départ
DelayedFlights = FOREACH ValidFlights GENERATE
                 (ArrDelay > 15 ? 1 : 0) AS Delayed, -- 1 si retard > 15 min, 0 sinon
                 Year, Month, DayofMonth, DayOfWeek,
                 (int)(DepTime / 100) AS Hour; -- Heure de départ (HH)

-- Calculer la proportion de retard par Année (Exemple)
DelayByYear_Group = GROUP DelayedFlights BY Year;
DelayByYear = FOREACH DelayByYear_Group GENERATE
              group AS Year,
              AVG(DelayedFlights.Delayed) AS DelayProportion; 

-- Calculer la proportion de retard par Heure (Exemple)
DelayByHour_Group = GROUP DelayedFlights BY Hour;
DelayByHour = FOREACH DelayByHour_Group GENERATE
              group AS Hour,
              AVG(DelayedFlights.Delayed) AS DelayProportion; 

-- DUMP DelayByHour;

4--Retards des Transporteurs
CarrierDelayByMonth = FOREACH CarrierDelayByMonth_Group GENERATE
                      group.UniqueCarrier AS Carrier,
                      group.Month AS Month,
                      AVG((CarrierDelayedFlights::ValidFlights::ArrDelay > 15 ? 1 : 0)) AS DelayProportion;

SortedCarrierDelay = ORDER CarrierDelayByMonth BY Carrier, Month;
DUMP SortedCarrierDelay;

5-- Itinéraires les Plus Fréquentés

-- 1. Créer une paire d'aéroports (Origin, Dest)
AirportPairs = FOREACH ValidFlights GENERATE Origin, Dest;

-- 2. Normaliser la paire pour qu'elle soit non ordonnée
NormalizedPairs = FOREACH AirportPairs GENERATE
                  (Origin < Dest ? Origin : Dest) AS Airport1,
                  (Origin < Dest ? Dest : Origin) AS Airport2;

-- 3. Grouper par la paire normalisée
ItinerairesGroup = GROUP NormalizedPairs BY (Airport1, Airport2);

-- 4. Compter la fréquence et classer
Frequences = FOREACH ItinerairesGroup GENERATE
             group.Airport1,
             group.Airport2,
             COUNT(NormalizedPairs) AS Frequency;

TopItineraires = ORDER Frequences BY Frequency DESC;
DUMP TopItineraires;