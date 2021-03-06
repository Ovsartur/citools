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
Перем ПараметрыВыполнения;

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
	Лог.Информация("Выполняется завершение пользовательских сеансов");

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
		Приложение.ЗавершитьРаботуПриложенияСОшибкой(СтрШаблон("Не удалось подключиться к кластеру баз данных. Описание: %1", ОписаниеОшибки()));
	КонецПопытки;

	ТаймаутОжиданияЗавершенияПользовательскихСеансов = Число(ПараметрыКоманды["lockstartat"]); // через 10 минут	
	ДатаНачалаБлокировкиИБ = ТекущаяДата() + ТаймаутОжиданияЗавершенияПользовательскихСеансов;
	СообщениеБлокировки = ПараметрыКоманды["lockmessage"];
	КодБлокировки = ПараметрыКоманды["uccode"];

	Лог.Отладка(СтрШаблон("Через %1 сек. база %2 будет заблокирована", ТаймаутОжиданияЗавершенияПользовательскихСеансов, ИнформационнаяБаза));
	Лог.Отладка(СтрШаблон("Начало блокировки - ""%1"", код блокировки - ""%2"", сообщение - ""%3""", ДатаНачалаБлокировкиИБ, КодБлокировки, СообщениеБлокировки));

	Попытка
		УправлениеКластером.БлокировкаИнформационнойБазы(ИнформационнаяБаза, СообщениеБлокировки, КодБлокировки, ДатаНачалаБлокировкиИБ,, Истина);
	Исключение
		// по какой-то причине не удалось установить блокировку на ИБ
		Приложение.ЗавершитьРаботуПриложенияСОшибкой(СтрШаблон("Не удалось заблокировать ИБ. Описание: %1", ОписаниеОшибки()));
	КонецПопытки;

	Лог.Отладка("Ожидаем завершения пользовательских сеансов");
	Приостановить(ТаймаутОжиданияЗавершенияПользовательскихСеансов * 1000);

	// убедимся что все сеансы завершились
	СписокСеансов = УправлениеКластером.СписокСеансовИнформационнойБазы(ИнформационнаяБаза);

	Если СписокСеансов.Количество() = 0 Тогда
		Лог.Отладка("Все сеансы с информационной базой успешно завершены");
		Возврат Приложение.РезультатыКоманд().Успех;
	КонецЕсли;

	Лог.Отладка("Обнаружено наличие незавершенных сеансов:");
	Для Каждого Сеанс Из СписокСеансов Цикл
		Лог.Отладка(СтрШаблон(" -- Пользователь - %1, Приложение - %2, Номер Сеанса - %3", Сеанс.Пользователь, Сеанс.Приложение, Сеанс.НомерСеанса));
	КонецЦикла;

	// попытаемся принудительно закрыть все соединения с базой
	Лог.Отладка("Принудительно завершаем все пользовательские сеансы");
	УправлениеКластером.ОтключитьСеансыИнформационнойБазы(ИнформационнаяБаза);
	Приостановить(1 * 60 * 1000); // 1 мин

	СписокСеансов = УправлениеКластером.СписокСеансовИнформационнойБазы(ИнформационнаяБаза);
	СеансыЗавершены = СписокСеансов.Количество() = 0;

	Если СеансыЗавершены Тогда
		Лог.Отладка("Отсутствут активные соединения с информационной базой");
		Возврат Приложение.РезультатыКоманд().Успех;
	КонецЕсли;

	Лог.Отладка("Обнаружено наличие незавершенных пользовательских сеанс:");
	Для Каждого Сеанс Из СписокСеансов Цикл
		Лог.Отладка(СтрШаблон(" -- Пользователь - %1, Приложение - %2, Номер Сеанса - %3", Сеанс.Пользователь, Сеанс.Приложение, Сеанс.НомерСеанса));
	КонецЦикла;

	Если НЕ СеансыЗавершены Тогда
		Приложение.ЗавершитьРаботуПриложенияСОшибкой("Не удалось завершить сеансы ИБ. Обновите конфигурацию БД вручную");
	КонецЕсли;

	Возврат Приложение.РезультатыКоманд().Успех;
	
КонецФункции // ВыполнитьКоманду