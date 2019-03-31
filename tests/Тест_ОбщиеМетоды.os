#Использовать asserts

#Использовать ".."

Перем КаталогВыполненияТестов;

Функция ПолучитьСписокТестов(ЮнитТестирование) Экспорт

	КоллекцияТестов = Новый Массив;

	КоллекцияТестов.Добавить("ТестДолжен_ПолучитьСтрокуСоединенияСРабочейБазой");
	КоллекцияТестов.Добавить("ТестДолжен_ОбернутьПутьВКавычки");
	КоллекцияТестов.Добавить("ТестДолжен_ПолучитьМассивВерсийХранилищаКДеплою");
	КоллекцияТестов.Добавить("ТестДолжен_ПолучитьCOMСоединениеСБазой");
	КоллекцияТестов.Добавить("ТестДолжен_СохранитьСтруктуруВФайлJSON");
	КоллекцияТестов.Добавить("ТестДолжен_ЗагрузитьФайлВСтруктуру");
	КоллекцияТестов.Добавить("ТестДолжен_ВыгрузитьВерсиюКонфигурацииИзХранилища");
	КоллекцияТестов.Добавить("ТестДолжен_СоздатьФайлПоставкиИзФайлаКонфигурации");
	КоллекцияТестов.Добавить("ТестДолжен_ОтфильтроватьСтрокиТаблицы");
	КоллекцияТестов.Добавить("ТестДолжен_ПолучитьПараметрыПерезапускаРабочихПроцессовКластера");
	КоллекцияТестов.Добавить("ТестДолжен_ПолучитьНастройкиКластераПоСтроке");
	КоллекцияТестов.Добавить("ТестДолжен_ПредоставитьПустойКаталог");

	Возврат КоллекцияТестов;
	
КонецФункции

Функция ПередЗапускомТеста() Экспорт

	ОчиститьВременныеФайлы();

	КаталогВыполненияТестов = ОбъединитьПути(ТекущийСценарий().Каталог, "files", "_temp");
	СоздатьКаталог(КаталогВыполненияТестов);
	
КонецФункции

Функция ПослеЗапускаТеста() Экспорт	

	ОчиститьВременныеФайлы();
	
КонецФункции

Процедура ОчиститьВременныеФайлы()

	ОбъектКаталог = Новый Файл(КаталогВыполненияТестов);
	Если ОбъектКаталог.Существует() Тогда
		УдалитьФайлы(КаталогВыполненияТестов);
	КонецЕсли;

КонецПроцедуры

Процедура ТестДолжен_ПолучитьСтрокуСоединенияСРабочейБазой() Экспорт

	Параметры = Новый Соответствие;
	Параметры.Вставить("base_product_path", Неопределено);
	Параметры.Вставить("cluster_name", "localhost");

	СтрокаСоединения = ОбщиеМетоды.ПолучитьСтрокуСоединенияСРабочейБазой(Параметры);
	Ожидаем.Что(СтрокаСоединения, "Не верно формируется строка соединения с базой").Равно("/Slocalhost\");


	Параметры = Новый Соответствие;
	Параметры.Вставить("base_product_path", ТекущийСценарий().Каталог);
	Параметры.Вставить("cluster_name", Неопределено);

	СтрокаСоединения = ОбщиеМетоды.ПолучитьСтрокуСоединенияСРабочейБазой(Параметры);
	Ожидаем.Что(СтрокаСоединения, "Не верно формируется строка соединения с базой").Равно("/F""" + ТекущийСценарий().Каталог + """");

	Параметры = Новый Соответствие;
	Параметры.Вставить("base_product_path", ТекущийСценарий().Каталог);
	Параметры.Вставить("cluster_name", "localhost");

	СтрокаСоединения = ОбщиеМетоды.ПолучитьСтрокуСоединенияСРабочейБазой(Параметры);
	Ожидаем.Что(СтрокаСоединения, "Не верно формируется строка соединения с базой").Равно("/F""" + ТекущийСценарий().Каталог + """");
	
КонецПроцедуры

Процедура ТестДолжен_ОбернутьПутьВКавычки() Экспорт

	ПроверяемаяСтрока = "Строка для проверки";
	РезультирующаяСтрока = """Строка для проверки""";
	Ожидаем.Что(ОбщиеМетоды.ОбернутьПутьВКавычки(ПроверяемаяСтрока), "Некорректное оборачивание кавыками").Равно(РезультирующаяСтрока);

	ПроверяемаяСтрокаСЭкранированием = "Произвольный\Путь\К\Файлу\";
	РезультирующаяСтрока = """Произвольный\Путь\К\Файлу""";
	Ожидаем.Что(ОбщиеМетоды.ОбернутьПутьВКавычки(ПроверяемаяСтрокаСЭкранированием), "Некорректное оборачивание кавыками").Равно(РезультирующаяСтрока);

КонецПроцедуры

Процедура ТестДолжен_ПолучитьМассивВерсийХранилищаКДеплою() Экспорт
	
	КаталогХранилища = ОбъединитьПути(ТекущийСценарий().Каталог, "files", "storage");

	ПараметрыВыполнения = Новый Соответствие;
	ПараметрыВыполнения.Вставить("storage_release_path", КаталогХранилища);
	ПараметрыВыполнения.Вставить("storage_release_user", "Администратор");
	ПараметрыВыполнения.Вставить("storage_release_pwd", "");

	КоллекцияВерсий = ОбщиеМетоды.ПолучитьМассивВерсийХранилищаКДеплою(Неопределено, ПараметрыВыполнения);
	Ожидаем.Что(КоллекцияВерсий, "Функция должна возвращать массив").ИмеетТип("Массив");
	Ожидаем.Что(КоллекцияВерсий.Количество(), "Неверное вычисление версий хранилища. Всего коммитов - 7").Равно(7);

	КоллекцияВерсий = ОбщиеМетоды.ПолучитьМассивВерсийХранилищаКДеплою(0, ПараметрыВыполнения);
	Ожидаем.Что(КоллекцияВерсий, "Функция должна возвращать массив").ИмеетТип("Массив");
	Ожидаем.Что(КоллекцияВерсий.Количество(), "Неверное вычисление версий хранилища. Всего коммитов - 7").Равно(7);

	КоллекцияВерсий = ОбщиеМетоды.ПолучитьМассивВерсийХранилищаКДеплою(3, ПараметрыВыполнения);
	Ожидаем.Что(КоллекцияВерсий, "Функция должна возвращать массив").ИмеетТип("Массив");
	Ожидаем.Что(КоллекцияВерсий.Количество(), "Неверное вычисление версий хранилища. Всего коммитов - 7").Равно(5);

КонецПроцедуры

Процедура ТестДолжен_ПолучитьCOMСоединениеСБазой() Экспорт
	
	КаталогТестовойБазы = ОбъединитьПути(ТекущийСценарий().Каталог, "files", "base");
	СтрокаСоединения = "";

	ПараметрыВыполнения = Новый Соответствие;
	ПараметрыВыполнения.Вставить("base_product_path", КаталогТестовойБазы);
	ПараметрыВыполнения.Вставить("base_product_user", "Администратор");
	ПараметрыВыполнения.Вставить("base_product_pwd", "");
	ПараметрыВыполнения.Вставить("uccode", "123");

	COMСоединение = ОбщиеМетоды.ПолучитьCOMСоединениеСБазой(ПараметрыВыполнения, СтрокаСоединения);

	Ожидаем.Что(COMСоединение, "Возвращен пустой объект").Существует();

КонецПроцедуры

Процедура ТестДолжен_СохранитьСтруктуруВФайлJSON() Экспорт
	
	ПутьКФайлу = ОбъединитьПути(КаталогВыполненияТестов, "test_param.json");
	Данные = Новый Структура;
	Данные.Вставить("Параметр", "citools");
	Данные.Вставить("ВерсияХранилища", 5);

	Результат = ОбщиеМетоды.СохранитьСтруктуруВФайлJSON(ПутьКФайлу, Данные, Истина);
	Ожидаем.Что(Результат, "Файл не создан").ЕстьИстина();

	ОбъектФайл = Новый Файл(ПутьКФайлу);
	ФайлСуществует = ОбъектФайл.Существует() и ОбъектФайл.ЭтоФайл();
	Ожидаем.Что(ФайлСуществует, "Файл не создан").ЕстьИстина();

	ПарсерСтрокиJSON = Новый ПарсерJSON();
	ЧтениеТекста = Новый ЧтениеТекста(ПутьКФайлу);
	СтрокаJSON = ЧтениеТекста.Прочитать();
	ЧтениеТекста.Закрыть();
	ДанныеФайла = ПарсерСтрокиJSON.ПрочитатьJSON(СтрокаJSON,,,Истина);
	Ожидаем.Что(ДанныеФайла, "Неверный тип данных").ИмеетТип("Структура");
	Ожидаем.Что(ДанныеФайла.ВерсияХранилища, "Неверные данные полей структуры").Равно(5);
	Ожидаем.Что(ДанныеФайла.Параметр, "Неверные данные полей структуры").Равно("citools");

	Данные = Новый Структура;
	Данные.Вставить("ВерсияХранилища", 25);

	Результат = ОбщиеМетоды.СохранитьСтруктуруВФайлJSON(ПутьКФайлу, Данные, Истина);
	Ожидаем.Что(Результат, "Файл не создан").ЕстьИстина();

	ПарсерСтрокиJSON = Новый ПарсерJSON();
	ЧтениеТекста = Новый ЧтениеТекста(ПутьКФайлу);
	СтрокаJSON = ЧтениеТекста.Прочитать();
	ЧтениеТекста.Закрыть();
	ДанныеФайла = ПарсерСтрокиJSON.ПрочитатьJSON(СтрокаJSON,,,Истина);
	Ожидаем.Что(ДанныеФайла, "Неверный тип данных").ИмеетТип("Структура");
	Ожидаем.Что(ДанныеФайла.ВерсияХранилища, "Неверные данные полей структуры").Равно(25);
	Ожидаем.Что(ДанныеФайла.Параметр, "Неверные данные полей структуры").Равно("citools");

КонецПроцедуры

Процедура ТестДолжен_ЗагрузитьФайлВСтруктуру() Экспорт

	ПутьКФайлу = ОбъединитьПути(КаталогВыполненияТестов, "test_load.json");

	СтруктураДанных = Новый Структура;
	СтруктураДанных.Вставить("Параметр1", Истина);
	СтруктураДанных.Вставить("Параметр2", 150);

	ПарсерСтрокиJSON = Новый ПарсерJSON();
	СтрокаJSON = ПарсерСтрокиJSON.ЗаписатьJSON(СтруктураДанных);

	ЗаписьТекста = Новый ЗаписьТекста(ПутьКФайлу);
	ЗаписьТекста.Записать(СтрокаJSON);
	ЗаписьТекста.Закрыть();

	СтруктураДанных = ОбщиеМетоды.ЗагрузитьФайлВСтруктуру(ПутьКФайлу);

	Ожидаем.Что(СтруктураДанных, "Неверный тип данных").ИмеетТип("Структура");
	Ожидаем.Что(СтруктураДанных.Параметр1, "Неверные данные полей структуры").ЕстьИстина();
	Ожидаем.Что(СтруктураДанных.Параметр2, "Неверные данные полей структуры").Равно(150);
	
КонецПроцедуры

Процедура ТестДолжен_ВыгрузитьВерсиюКонфигурацииИзХранилища() Экспорт

	ПутьКХранилищу = ОбъединитьПути(ТекущийСценарий().Каталог, "files", "storage");
	НомерВерсииХранилища = 3;
	ПутьКФайлуКонфигурации = ОбъединитьПути(КаталогВыполненияТестов, Строка(НомерВерсииХранилища) + ".cf");
	
	ПараметрыХранилища = Новый Структура;
	ПараметрыХранилища.Вставить("storage_release_path", ПутьКХранилищу);
	ПараметрыХранилища.Вставить("storage_release_user", "Администратор");
	ПараметрыХранилища.Вставить("storage_release_pwd", "");

	ОбщиеМетоды.ВыгрузитьВерсиюКонфигурацииИзХранилища(ПараметрыХранилища, ПутьКФайлуКонфигурации, НомерВерсииХранилища);

	ОбъектФайл = Новый Файл(ПутьКФайлуКонфигурации);
	ФайлСуществует = ОбъектФайл.Существует() и ОбъектФайл.ЭтоФайл();
	Ожидаем.Что(ФайлСуществует, "Файл не создан").ЕстьИстина();
	
КонецПроцедуры

Процедура ТестДолжен_СоздатьФайлПоставкиИзФайлаКонфигурации(ПутьКФайлуКонфигурации) Экспорт

	ПутьКХранилищу = ОбъединитьПути(ТекущийСценарий().Каталог, "files", "storage");
	НомерВерсииХранилища = 7;
	ПутьКФайлуКонфигурации = ОбъединитьПути(КаталогВыполненияТестов, Строка(НомерВерсииХранилища) + ".cf");
	ПутьКФайлуПоставки = ОбъединитьПути(КаталогВыполненияТестов, "1Cv8.cf");
	ПутьФайлаПоставкиОбновления = ОбъединитьПути(КаталогВыполненияТестов, "1Cv8.cfu");
	
	ПараметрыХранилища = Новый Структура;
	ПараметрыХранилища.Вставить("storage_release_path", ПутьКХранилищу);
	ПараметрыХранилища.Вставить("storage_release_user", "Администратор");
	ПараметрыХранилища.Вставить("storage_release_pwd", "");

	ОбщиеМетоды.ВыгрузитьВерсиюКонфигурацииИзХранилища(ПараметрыХранилища, ПутьКФайлуКонфигурации, НомерВерсииХранилища);

	ОбъектФайл = Новый Файл(ПутьКФайлуКонфигурации);
	ФайлСуществует = ОбъектФайл.Существует() и ОбъектФайл.ЭтоФайл();
	Ожидаем.Что(ФайлСуществует, "Файл конфигурации не создан").ЕстьИстина();

	ОбщиеМетоды.СоздатьФайлПоставкиИзФайлаКонфигурации(ПутьКФайлуКонфигурации, ПутьКФайлуПоставки);

	ОбъектФайл = Новый Файл(ПутьКФайлуПоставки);
	ФайлСуществует = ОбъектФайл.Существует() и ОбъектФайл.ЭтоФайл();
	Ожидаем.Что(ФайлСуществует, "Файл поставки не создан").ЕстьИстина();
	
КонецПроцедуры

Процедура ТестДолжен_ОтфильтроватьСтрокиТаблицы() Экспорт

	ТестоваяТаблица = Новый ТаблицаЗначений();

	ТестоваяТаблица.Колонки.Добавить("Идентификатор");
	ТестоваяТаблица.Колонки.Добавить("Приложение");
	ТестоваяТаблица.Колонки.Добавить("Процесс");

	ЗначенияФильтра = Новый Массив;
	ЗначенияФильтра.Добавить("BackgroundJob");
	Фильтр = Новый Структура;
	Фильтр.Вставить("Приложение", ЗначенияФильтра);

	РезультирующаяТаблица = ОбщиеМетоды.ОтфильтроватьСтрокиТаблицы(ТестоваяТаблица, ЗначенияФильтра);
	Ожидаем.Что(РезультирующаяТаблица, "Функция должна возвращать таблицу значений").ИмеетТип("ТаблицаЗначений");
	Ожидаем.Что(РезультирующаяТаблица.Количество(), "Фильтрация пустой таблицы должна возвращать пустую таблицу").Равно(0);

	ЗначенияТаблицы = Новый Массив;
	ЗначенияТаблицы.Добавить(Новый Структура("Идентификатор, Приложение, Процесс", 1, "BackgroundJob", "Процесс_1"));
	ЗначенияТаблицы.Добавить(Новый Структура("Идентификатор, Приложение, Процесс", 2, "BackgroundJob", "Процесс_2"));
	ЗначенияТаблицы.Добавить(Новый Структура("Идентификатор, Приложение, Процесс", 3, "some_value_1", "Процесс_3"));
	ЗначенияТаблицы.Добавить(Новый Структура("Идентификатор, Приложение, Процесс", 4, "some_value_2", "Процесс_4"));
	ЗначенияТаблицы.Добавить(Новый Структура("Идентификатор, Приложение, Процесс", 5, "some_value_3", "Процесс_5"));
	ЗначенияТаблицы.Добавить(Новый Структура("Идентификатор, Приложение, Процесс", 6, "some_value_4", "Процесс_6"));

	Для Каждого СтрокаЗначений Из ЗначенияТаблицы Цикл
		ЗаполнитьЗначенияСвойств(ТестоваяТаблица.Добавить(), СтрокаЗначений);
	КонецЦикла;

	РезультирующаяТаблица = ОбщиеМетоды.ОтфильтроватьСтрокиТаблицы(ТестоваяТаблица, Фильтр);
	Ожидаем.Что(РезультирующаяТаблица, "Функция должна возвращать таблицу значений").ИмеетТип("ТаблицаЗначений");
	Ожидаем.Что(РезультирующаяТаблица.Количество(), "Некорректная фильтрация строк таблицы значений").Равно(2);


	ЗначенияФильтра = Новый Массив;
	ЗначенияФильтра.Добавить("BackgroundJob");
	ЗначенияФильтра.Добавить("COMConnection");
	Фильтр = Новый Структура;
	Фильтр.Вставить("Приложение", ЗначенияФильтра);

	ЗначенияТаблицы = Новый Массив;
	ЗначенияТаблицы.Добавить(Новый Структура("Идентификатор, Приложение, Процесс", 1, "BackgroundJob", "Процесс_1"));
	ЗначенияТаблицы.Добавить(Новый Структура("Идентификатор, Приложение, Процесс", 2, "BackgroundJob", "Процесс_2"));
	ЗначенияТаблицы.Добавить(Новый Структура("Идентификатор, Приложение, Процесс", 3, "some_value_1", "Процесс_3"));
	ЗначенияТаблицы.Добавить(Новый Структура("Идентификатор, Приложение, Процесс", 4, "some_value_2", "Процесс_4"));
	ЗначенияТаблицы.Добавить(Новый Структура("Идентификатор, Приложение, Процесс", 5, "some_value_3", "Процесс_5"));
	ЗначенияТаблицы.Добавить(Новый Структура("Идентификатор, Приложение, Процесс", 6, "some_value_4", "Процесс_6"));
	ЗначенияТаблицы.Добавить(Новый Структура("Идентификатор, Приложение, Процесс", 7, "COMConnection", "Процесс_7"));
	ЗначенияТаблицы.Добавить(Новый Структура("Идентификатор, Приложение, Процесс", 8, "COMConnection", "Процесс_8"));

	ТестоваяТаблица.Очистить();
	
	Для Каждого СтрокаЗначений Из ЗначенияТаблицы Цикл
		ЗаполнитьЗначенияСвойств(ТестоваяТаблица.Добавить(), СтрокаЗначений);
	КонецЦикла;

	РезультирующаяТаблица = ОбщиеМетоды.ОтфильтроватьСтрокиТаблицы(ТестоваяТаблица, Фильтр);
	Ожидаем.Что(РезультирующаяТаблица, "Функция должна возвращать таблицу значений").ИмеетТип("ТаблицаЗначений");
	Ожидаем.Что(РезультирующаяТаблица.Количество(), "Некорректная фильтрация строк таблицы значений").Равно(4);	
	
КонецПроцедуры

Процедура ТестДолжен_ПолучитьПараметрыПерезапускаРабочихПроцессовКластера() Экспорт

	ТестоваяСтрокаШаблон = 
		"""C:\Program files\rac.exe"" cluster update --cluster=%1 --agent-user=%2 --agent-pwd=%3 --kill-problem-processes=%4 --lifetime-limit=%5 --expiration-timeout=%6 %7:%8";

	ПользовательКластера = "User";
	ПарольПользователяКластера = "user-pwd";
	ИдентификаторЛокальногоКластера = "14659f18-248f-4b89-a699-c3f93b0bc642";
	ПутьКлиентаАдминистрирования = ОбъединитьПути("C:\", "Program files", "rac.exe");
	Хост = "localhost";
	Порт = "1515";
	ПринудительноеЗавершение = Истина;
	ПериодПринудительногоЗавершения = 4000; //сек
	ПериодПерезапуска = 0; //сек

	Если ПринудительноеЗавершение Тогда
		ПринудительноеЗавершениеСтрокой = "yes";
	Иначе
		ПринудительноеЗавершениеСтрокой = "no";
	КонецЕсли;

	ТестоваяСтрока = СтрШаблон(ТестоваяСтрокаШаблон, ИдентификаторЛокальногоКластера, ПользовательКластера, ПарольПользователяКластера, 
		ПринудительноеЗавершениеСтрокой, ПериодПринудительногоЗавершения, ПериодПерезапуска, Хост, Порт);

	ПараметрыПерезапуска = ОбщиеМетоды.ПараметрыПерезапускаРабочихПроцессовКластера(ПользовательКластера, ПарольПользователяКластера, ИдентификаторЛокальногоКластера,
		ПутьКлиентаАдминистрирования, Хост, Порт, ПринудительноеЗавершение, ПериодПринудительногоЗавершения, ПериодПерезапуска);

	ИтоговаяСтрока = СтрСоединить(ПараметрыПерезапуска, " ");

	Ожидаем.Что(ТестоваяСтрока = ИтоговаяСтрока, "Неверное формирование параметров перезапуска сеансов").ЕстьИстина();
	
КонецПроцедуры

Процедура ТестДолжен_ПолучитьНастройкиКластераПоСтроке() Экспорт

	ПараметрыСтрокой = 
	"  Параметр_1      : Значение_1" + Символы.ВК + Символы.ПС + 
	"Параметр_2     : 	 Значение_2" + Символы.ВК + Символы.ПС + 
	"      Параметр-3  : Значение-3" + Символы.ВК + Символы.ПС + 
	"  Параметр-4      :Значение_4 ";

	СтруктураПараметров = ОбщиеМетоды.ПолучитьНастройкиКластераПоСтроке(ПараметрыСтрокой);

	Ожидаем.Что(СтруктураПараметров.Количество(), "Неверное количество элементов структуры").Равно(4);

	Ожидаем.Что(СтруктураПараметров.Свойство("Параметр_1"), "Неверный первый ключ структуры, должен быть").ЕстьИстина();
	Ожидаем.Что(СтруктураПараметров.Параметр_1 = "Значение_1", "Неверное значение первого ключа структуры").ЕстьИстина();

	Ожидаем.Что(СтруктураПараметров.Свойство("Параметр_2"), "Неверный второй ключ структуры").ЕстьИстина();
	Ожидаем.Что(СтруктураПараметров.Параметр_2 = "Значение_2", "Неверное значение второго ключа структуры").ЕстьИстина();

	Ожидаем.Что(СтруктураПараметров.Свойство("Параметр_3"), "Неверный третий ключ структуры").ЕстьИстина();
	Ожидаем.Что(СтруктураПараметров.Параметр_3 = "Значение-3", "Неверное значение третьего ключа структуры").ЕстьИстина();

	Ожидаем.Что(СтруктураПараметров.Свойство("Параметр_4"), "Неверный четвертый ключ структуры").ЕстьИстина();
	Ожидаем.Что(СтруктураПараметров.Параметр_4 = "Значение_4", "Неверное значение четвертого ключа структуры").ЕстьИстина();

КонецПроцедуры

Процедура ТестДолжен_ПредоставитьПустойКаталог() Экспорт

	ОбщиеМетоды.ПредоставитьПустойКаталог(ОбъединитьПути(КаталогВыполненияТестов, "foo"));
	
	СуществующийКаталог = Новый Файл(ОбъединитьПути(КаталогВыполненияТестов, "foo"));	
	Ожидаем.Что(СуществующийКаталог.Существует(), СтрШаблон("Каталог удален - %1. Должен существовать", ОбъединитьПути(КаталогВыполненияТестов, "foo"))).ЕстьИстина();


	СоздатьКаталог(ОбъединитьПути(КаталогВыполненияТестов, "foo", "bar"));
	ПутьКФайлу_1 = ОбъединитьПути(КаталогВыполненияТестов, "foo", "file.txt");
	ПутьКФайлу_2 = ОбъединитьПути(КаталогВыполненияТестов, "foo", "bar", "file.txt");

	ЗаписьТекста = Новый ЗаписьТекста(ПутьКФайлу_1);
	ЗаписьТекста.ЗаписатьСтроку("строка");
	ЗаписьТекста.Закрыть();

	ЗаписьТекста = Новый ЗаписьТекста(ПутьКФайлу_2);
	ЗаписьТекста.ЗаписатьСтроку("строка");
	ЗаписьТекста.Закрыть();

	ОбщиеМетоды.ПредоставитьПустойКаталог(ОбъединитьПути(КаталогВыполненияТестов, "foo"));

	Файл_1 = Новый Файл(ПутьКФайлу_1);
	Файл_2 = Новый Файл(ПутьКФайлу_2);
	СуществующийКаталог = Новый Файл(ОбъединитьПути(КаталогВыполненияТестов, "foo"));
	УдаленныйКаталог = Новый Файл(ОбъединитьПути(КаталогВыполненияТестов, "foo", "bar"));

	Ожидаем.Что(НЕ Файл_1.Существует(), СтрШаблон("Файл не удален - %1", ПутьКФайлу_1)).ЕстьИстина();
	Ожидаем.Что(НЕ Файл_2.Существует(), СтрШаблон("Файл не удален - %1", ПутьКФайлу_2)).ЕстьИстина();
	Ожидаем.Что(НЕ УдаленныйКаталог.Существует(), СтрШаблон("Каталог не удален - %1", ОбъединитьПути(КаталогВыполненияТестов, "foo", "bar"))).ЕстьИстина();
	Ожидаем.Что(СуществующийКаталог.Существует(), СтрШаблон("Каталог удален - %1. Должен существовать", ОбъединитьПути(КаталогВыполненияТестов, "foo"))).ЕстьИстина();
	
КонецПроцедуры
