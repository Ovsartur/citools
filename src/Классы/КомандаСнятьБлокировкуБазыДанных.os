///////////////////////////////////////////////////////////////////////////////
//
// Служебный модуль с реализацией работы команды help
//
///////////////////////////////////////////////////////////////////////////////

#Использовать logos
#Использовать asserts
#Использовать v8storage
#Использовать v8rac
#Использовать tempfiles

Перем Лог;

Процедура НастроитьКоманду(Знач Команда, Знач Парсер) Экспорт

	Парсер.ДобавитьПозиционныйПараметрКоманды(Команда, "ИмяБазы", "Имя информационной базы, которую нужно проверить");
	
КонецПроцедуры // НастроитьКоманду

// Выполняет логику команды
// 
// Параметры:
//   ПараметрыКоманды - Соответствие - Соответствие ключей командной строки и их значений
//   Приложение - Модуль - Модуль менеджера приложения
//
Функция ВыполнитьКоманду(Знач ПараметрыКоманды, Знач Приложение) Экспорт
	
	Лог = Приложение.ПолучитьЛог();
	Лог.Информация("Запуск процесса снятия блокировки с базы данных");

	ИнформационнаяБаза = ПараметрыКоманды["ИмяБазы"];
	Если ИнформационнаяБаза = Неопределено Тогда
		Приложение.ЗавершитьРаботуПриложенияСОшибкой("Попытка выполнения команды без указания имени базы");
	КонецЕсли;

	УправлениеКластером = Новый УправлениеКластером;

	УправлениеКластером.УстановитьКластер(ПараметрыКоманды["cluster_name"]);
	УправлениеКластером.ИспользоватьВерсию("8.3");
	УправлениеКластером.УстановитьАвторизациюКластера(ПараметрыКоманды["cluster_user"], ПараметрыКоманды["cluster_pwd"]);
	УправлениеКластером.УстановитьАвторизациюИнформационнойБазы(ИнформационнаяБаза, ПараметрыКоманды["base_product_user"], ПараметрыКоманды["base_product_pwd"]);
	
	Попытка
		УправлениеКластером.Подключить();
	Исключение
		Приложение.ЗавершитьРаботуПриложенияСОшибкой("Не удалось подключиться к кластеру баз данных. Описание: " + ОписаниеОшибки());
	КонецПопытки;
	
	Попытка
		УправлениеКластером.СнятьБлокировкуИнформационнойБазы(ИнформационнаяБаза);
	Исключение
		Приложение.ЗавершитьРаботуПриложенияСОшибкой("Не удалось снять блокировку с базы данных.. Описание: " + ОписаниеОшибки());
	КонецПопытки;	

	Возврат Приложение.РезультатыКоманд().Успех;
		
КонецФункции // ВыполнитьКоманду
