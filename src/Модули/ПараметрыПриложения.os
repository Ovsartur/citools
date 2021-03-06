///////////////////////////////////////////////////////////////////////////////
//
// Служебный модуль с набором служебных параметров приложения
//
// При создании нового приложения обязательно внести изменение 
// в ф-ии ИмяПродукта, указав имя вашего приложения.
//
// При выпуске новой версии обязательно изменить ее значение
// в ф-ии ВерсияПродукта
//
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
// СВОЙСТВА ПРОДУКТА

Перем КорневойПутьПроекта Экспорт;

// ВерсияПродукта
//	Возвращает текущую версию продукта
//
// Возвращаемое значение:
//   Строка   - Значение текущей версии продукта
//
Функция ВерсияПродукта() Экспорт
	
	Возврат "1.0";
	
КонецФункции // ВерсияПродукта

// ИмяПродукта
//	Возвращает имя продукта
//
// Возвращаемое значение:
//   Строка   - Значение имени продукта
//
Функция ИмяПродукта() Экспорт
	
	Возврат "citools";
	
КонецФункции // ИмяПродукта

///////////////////////////////////////////////////////////////////////////////
// ЛОГИРОВАНИЕ

//	Форматирование логов
//   См. описание метода "УстановитьРаскладку" библиотеки logos
//
Функция Форматировать(Знач Уровень, Знач Сообщение) Экспорт

	Возврат СтрШаблон("%1: %2 - %3", ТекущаяДата(), УровниЛога.НаименованиеУровня(Уровень), Сообщение);

КонецФункции
	
// ИмяЛогаСистемы
//	Возвращает идентификатор лога приложения
//
// Возвращаемое значение:
//   Строка   - Значение идентификатора лога приложения
//
Функция ИмяЛогаСистемы() Экспорт
	
	Возврат "oscript.app." + ИмяПродукта();
	
КонецФункции // ИмяЛогаСистемы

///////////////////////////////////////////////////////////////////////////////
// НАСТРОЙКА КОМАНД

// Возвращает имя команды "version" (ключ командной строки)
//
//  Возвращаемое значение:
//   Строка - имя команды
//
Функция ИмяКомандыВерсия() Экспорт
	
	Возврат "version";

КонецФункции // ИмяКомандыВерсия


// Возвращает имя команды "help" (ключ командной строки)
//
//  Возвращаемое значение:
//   Строка - имя команды
//
Функция ИмяКомандыПомощь() Экспорт

	Возврат "help";
	
КонецФункции // ИмяКомандыПомощь()


// ИмяКомандыПоУмолчанию
// 	Одна из команд может вызываться неявно, без указания команды.
// 	Иными словами, здесь указывается какой обработчик надо вызывать, если приложение запущено без какой-либо команды
// 	myapp /home/user/somefile.txt будет аналогично myapp default-action /home/user/somefile.txt 
//
// Возвращаемое значение:
// 	Строка - имя команды по умолчанию
Функция ИмяКомандыПоУмолчанию() Экспорт
	
	// Возврат "default-action";
	Возврат ИмяКомандыПомощь();
	
КонецФункции // ИмяКомандыПоУмолчанию

// НастроитьКомандыПриложения
//	Регистрирует классы обрабатывающие команды прилоложения
// 
// Параметры:
//	Приложение - Модуль - Модуль менеджера приложения
Процедура  НастроитьКомандыПриложения(Знач Приложение) Экспорт
	
	Приложение.ДобавитьКоманду(
		ИмяКомандыПомощь(), 
		"КомандаСправкаПоПараметрам", 
		"Выводит справку по командам");

	Приложение.ДобавитьКоманду(
		ИмяКомандыВерсия(), 
		"КомандаVersion",             
		"Выводит версию приложения");

	Приложение.ДобавитьКоманду(
		"check-update", 
		"КомандаПроверитьНеобходимостьОбновления", 
		"Выполняет проверку необходимости запуска процесса обновлениия");

	Приложение.ДобавитьКоманду(
		"check-update-tasks", 
		"КомандаПроверитьЗавершениеОбработчиковПредыдущегоОбновления", 
		"Проверяет завершенность работы обработчиков обновления");

	Приложение.ДобавитьКоманду(
		"lock-background-jobs",
		"КомандаЗаблокироватьРегламентныеЗадания", 
		"Команда блокировки регламентных заданий");
	
	Приложение.ДобавитьКоманду(
		"create-distribution-file", 
		"КомандаПодготовитьФайлПоставки", 
		"Создает файл поставки следующий после версии хранилища из рабочей базы в формате <НомерВерсии>.cf");

	Приложение.ДобавитьКоманду(
		"update-db-conf", 
		"КомандаВыполнитьОбновлениеОсновнойКонфигурации", 
		"Команда обновления основной конфигурации базы данных");

	Приложение.ДобавитьКоманду(
		"wait-background-jobs", 
		"КомандаОжидатьЗавершенияРегламентныхЗаданий", 
		"Команда ожидания завершения регламентных заданий");

	Приложение.ДобавитьКоманду(
		"lock-sessions", 
		"КомандаБлокироватьПользовательскиеСеансы", 
		"Команда блокирует пользовательские сеансы и ожидает их завершения");

	Приложение.ДобавитьКоманду(
		"update-db", 
		"КомандаВыполнитьОбновлениеКонфигурацииБазыДанных", 
		"Команда выполняет обновление конфигурации базы данных");

	Приложение.ДобавитьКоманду(
		"run-update-handlers", 
		"КомандаЗапуститьОбработчикиОбновления", 
		"Команда выполняет запуск обработчиков обновления информационной базы");
	
	Приложение.ДобавитьКоманду(
		"unlock", 
		"КомандаСнятьБлокировкуБазыДанных", 
		"Команда снимает блокировку базы данных");	

	// Приложение.ДобавитьКоманду("<Имя команды>", "<Класс реализации>", "<Описание команды>");
	
КонецПроцедуры // ПриРегистрацииКомандПриложения/КомандаОбновитьРабочуюБазуЗапуститьОбработчики


