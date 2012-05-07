# -*- encoding : utf-8 -*-
require 'date'
require 'time'

class Date
	Date::ABBR_MONTHNAMES = [nil, "Jan", "Fév", "Mar", "Avr", "Mai", 
	"Juin", "Juil", "Août", "Sep", "Oct", "Nov", "Déc"]
	Date::MONTHNAMES = [nil, "Janvier", "Février", "Mars", "Avril", "Mai", "Juin", "Juillet", "Août", "Septembre", "Octobre", "Novembre", "Décembre"]
	Date::ABBR_DAYNAMES = %w(Dim Lun Mar Mer Jeu Ven Sam)
	Date::DAYNAMES = %w(Dimanche Lundi Mardi Mercredi Jeudi Vendredi Samedi)
end
