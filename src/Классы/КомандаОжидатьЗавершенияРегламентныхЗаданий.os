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
	Лог.Информация("Выполняется команда ожидания завершения работы фоновых заданий");

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

	ЗначенияФильтра = Новый Массив;
	ЗначенияФильтра.Добавить("BackgroundJob");
	ФильтрФоновыхЗаданий = Новый Структура;
	ФильтрФоновыхЗаданий.Вставить("Приложение", ЗначенияФильтра);

	СписокСеансов = УправлениеКластером.СписокСеансовИнформационнойБазы(ИнформационнаяБаза);
	СписокФоновыхЗаданий = ОбщиеМетоды.ОтфильтроватьСтрокиТаблицы(СписокСеансов, ФильтрФоновыхЗаданий);

	Если СписокФоновыхЗаданий.Количество() = 0 Тогда
		Лог.Отладка("Все фоновые задания успешно завершились");
		Возврат Приложение.РезультатыКоманд().Успех;
	КонецЕсли;

	Лог.Отладка("Обнаружено наличие незавершенных фоновых заданий:");
	Для Каждого ФоновоеЗадание Из СписокФоновыхЗаданий Цикл
		Лог.Отладка(СтрШаблон(" -- Пользователь - %1, Приложение - %2, Номер Сеанса - %3", ФоновоеЗадание.Пользователь, ФоновоеЗадание.Приложение, ФоновоеЗадание.НомерСеанса));
	КонецЦикла;

	// Ждем завершения в течение WaitClosingScheduledJobs секунд
	ДатаНачалаОжидания 		= ТекущаяДата();
	ПредельноеВремяОжидания = 120;//Число(ПараметрыКоманды.Получить("WaitClosingScheduledJobs"));
	ТаймаутОжидания 		= 30;//Число(ПараметрыКоманды.Получить("WaitTimeout"));

	ФоновыеЗаданияЗавершены = Ложь;

	// задания заблокированы, ждем их самостоятельного завершения
	Лог.Отладка(СтрШаблон("Ожидаем завершения работы фоновых заданий в течение ""%1 сек""", ПредельноеВремяОжидания));
	Пока (ТекущаяДата() - ДатаНачалаОжидания) <= ПредельноеВремяОжидания Цикл
		Приостановить(ТаймаутОжидания * 1000); // мс
		СписокСеансов = УправлениеКластером.СписокСеансовИнформационнойБазы(ИнформационнаяБаза);
		СписокФоновыхЗаданий = ОбщиеМетоды.ОтфильтроватьСтрокиТаблицы(СписокСеансов, ФильтрФоновыхЗаданий);
		Если СписокФоновыхЗаданий.Количество() = 0 Тогда
			ФоновыеЗаданияЗавершены = Истина;
			Прервать;
		КонецЕсли;
	КонецЦикла;

	Если ФоновыеЗаданияЗавершены Тогда
		Лог.Отладка("Все фоновые задания успешно завершились");
		Возврат Приложение.РезультатыКоманд().Успех;
	КонецЕсли;

	Лог.Отладка("Попытка принудительного отключения работающих сеансов:");
	
	// попытаемся принудительно отключить зависшие фоновые сеансы
	СписокСеансов = УправлениеКластером.СписокСеансовИнформационнойБазы(ИнформационнаяБаза);
	УправлениеКластером.ОтключитьСеансыИнформационнойБазы(ИнформационнаяБаза, ФильтрФоновыхЗаданий);

	// не известно нужно ли ожидание принудительного завершения сеансов
	Приостановить(1 * 60 * 1000); // мс

	СписокСеансов = УправлениеКластером.СписокСеансовИнформационнойБазы(ИнформационнаяБаза);
	СписокФоновыхЗаданий = ОбщиеМетоды.ОтфильтроватьСтрокиТаблицы(СписокСеансов, ФильтрФоновыхЗаданий);

	Если СписокФоновыхЗаданий.Количество() = 0 Тогда
		Лог.Отладка("Все фоновые задания успешно завершились");
		Возврат Приложение.РезультатыКоманд().Успех;
	КонецЕсли;

	Лог.Отладка("Не удалось принудительно завершить фоновые задания:");
	Для Каждого ФоновоеЗадание Из СписокФоновыхЗаданий Цикл
		Лог.Отладка(СтрШаблон(" -- Пользователь - %1, Приложение - %2, Номер Сеанса - %3", ФоновоеЗадание.Пользователь, ФоновоеЗадание.Приложение, ФоновоеЗадание.НомерСеанса));
	КонецЦикла;

	Лог.Отладка("Выполним перезапуск процессов с зависшими заданиями");

	// выполним перезапуск зависших сеансов
	ПараметрыКомандыКластера = Новый Массив; 
	ПараметрыКомандыКластера.Добавить("cluster");
	ПараметрыКомандыКластера.Добавить("list");

	НастройкиКластераСтрокой = УправлениеКластером.ВыполнитьКоманду(ПараметрыКомандыКластера);
	ИсходныеНастройкиКластера = ОбщиеМетоды.ПолучитьНастройкиКластераПоСтроке(НастройкиКластераСтрокой);

	ПараметрыПерезапуска = ОбщиеМетоды.ПараметрыПерезапускаРабочихПроцессовКластера(
		ПараметрыКоманды["cluster_user"], 
		ПараметрыКоманды["cluster_pwd"], 
		ИсходныеНастройкиКластера.Cluster,
		УправлениеКластером.ПолучитьПутьКлиентаАдминистрирования(),
		УправлениеКластером.ПолучитьАдресСервера(), 
		УправлениеКластером.ПолучитьПортСервера(),
		Истина,											// Принудительно завершать проблемные процессы
		120, 											// интервал перезапуска [сек]
		0);												// выключенные процессы останавливать через [сек]

	Команда = Новый Команда;
	Команда.ПоказыватьВыводНемедленно(Истина);
	Команда.УстановитьСтрокуЗапуска(СтрСоединить(ПараметрыПерезапуска, " "));
	Лог.Отладка(СтрШаблон("Выполняется команда <%1>", СтрСоединить(ПараметрыПерезапуска, " ")));	
	РезультатВыполнения = Команда.Исполнить();

	Если РезультатВыполнения <> Приложение.РезультатыКоманд().Успех Тогда
		Лог.Отладка("Не удалось изменить параметры кластера для принудительного перезапуска сеансов");
		Лог.Отладка(СтрШаблон("%1", Команда.ПолучитьВывод()));
		Приложение.ЗавершитьРаботуПриложенияСОшибкой("Выполните обновление конфигурации базы данных вручную");
	КонецЕсли;

	// ожидаем перезапуска зависших сеансов
	Приостановить(3 * 60 * 1000); // мс

	// восстановим исходные настройки кластера
	ПараметрыПерезапуска = ОбщиеМетоды.ПараметрыПерезапускаРабочихПроцессовКластера(
		ПараметрыКоманды["cluster_user"], 
		ПараметрыКоманды["cluster_pwd"], 
		ИсходныеНастройкиКластера.Cluster,
		УправлениеКластером.ПолучитьПутьКлиентаАдминистрирования(),
		УправлениеКластером.ПолучитьАдресСервера(), 
		УправлениеКластером.ПолучитьПортСервера(),
		ИсходныеНастройкиКластера.kill_problem_processes, 
		ИсходныеНастройкиКластера.lifetime_limit, 
		ИсходныеНастройкиКластера.expiration_timeout);

	Команда = Новый Команда;
	Команда.ПоказыватьВыводНемедленно(Истина);
	Команда.УстановитьСтрокуЗапуска(СтрСоединить(ПараметрыПерезапуска, " "));
	Лог.Отладка(СтрШаблон("Выполняется команда <%1>", СтрСоединить(ПараметрыПерезапуска, " ")));	
	
	РезультатВыполнения = Команда.Исполнить();

	Если РезультатВыполнения <> Приложение.РезультатыКоманд().Успех Тогда
		Лог.Предупреждение("Не удалось восстановить исходные параметры кластера!!! Выполните самостоятельно!");
		Лог.Предупреждение(СтрШаблон("%1", Команда.ПолучитьВывод()));
	КонецЕсли;
	
	СписокСоединений = УправлениеКластером.СписокСоединенийИнформационнойБазы(ИнформационнаяБаза);
	СписокФоновыхЗаданий = ОбщиеМетоды.ОтфильтроватьСтрокиТаблицы(СписокСоединений, ФильтрФоновыхЗаданий);

	Если СписокФоновыхЗаданий.Количество() > 0 Тогда
		Лог.Отладка("Не удалось принудительно завершить фоновые задания:");
		Для Каждого ФоновоеЗадание Из СписокФоновыхЗаданий Цикл
			Лог.Отладка(СтрШаблон(" -- Процесс - %1, Приложение - %2, Номер Сеанса - %3", ФоновоеЗадание.Процесс, ФоновоеЗадание.Приложение, ФоновоеЗадание.НомерСеанса));
		КонецЦикла;
		Приложение.ЗавершитьРаботуПриложенияСОшибкой("Выполните обновление конфигурации базы данных вручную");
	КонецЕсли;

	Лог.Отладка("Все фоновые задания успешно завершились");

	Возврат Приложение.РезультатыКоманд().Успех;
		
КонецФункции // ВыполнитьКоманду
