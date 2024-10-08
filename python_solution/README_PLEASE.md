### **Данную задачу можно было реализовать несколькими способами:**
1. Использовать DAG в Airflow для автоматической обработки.
2. Создание Python приложения
3. Простой подход с помощью Jupyter Notebook для визуального анализа и тестирования.

Каждый вариант имеет свои плюсы в зависимости от цели и объема данных. 

### **Overall conclusion for parsing**
Также следует добавить описание процесса, зачем то и или иное действие было добавлено в пайплайн. 

При первичном анализе данных было выявлено некоторые проблемы которые в дальшейнем нужно было решить для правильного решения, а именно:
1. Сразу были замечены абсолютно одинаковые списки словарей, у которых `id` разный, но `application_date` может быть что одинаковый до милисекунду, а может быть разный. 
- **Решение**: Сортировка по `id`, `application_date`, `contracts` и удаление дублей при условии полного совпадения строки `contracts` и выбор последнего. Было предположение, что последнее сообщение по дате является самым верным. 

2. Тип данных `id`, `application_date` и типы данных из словарей в списке требовали конвертации. При этом в сообщениях были и форматы данных, которые не поддавались конвертации и пришлось максимально привести к универсальной форме для дальнейшего расчета фичей. 
- **Решение**: Универсализация колонок дат и дальнейшая конвертация для подсчета фичей.

3. Отсутствие документации данных. Предположения что данные могут быть из брокера сообщений, данные которые были достали из определенной ручки или пришли напряму из системы были опровержены отсутствием документации и большим количеством отсутствующих значений. 
- **Решение**: Учитывание максимально возможных сценариев обработки. При этом для каждого из способов получения применимы различны стратегии обработки. Стриминговые данные можно напрямую лить в DWH через python-приложения. Если это batch-процесс - то оркестратором Airflow. Если же это разовый процесс обработки такого типа данных, **то конечно же лучше довести весь процесс до автоматизма**. 
---

### **Overall conclusion for calculating features**
Следует описать логику обработки в моем понимании, так как не совсем были ясны условия для расчета фич. 

1. **tot_claim_cnt_l180d**. 
- **Решение**: Данная фича предполагает расчет количества претензий за последние полгода. Я взял полгода от `application_date` и расчитал скользящую среднюю для каждой даты приложения. Тем самым получил количество претензий за полгода. 
- **Сопутствующие проблема**: Основной проблемой был поиск даты от которого бы велся подсчет количества претензий. При использовании даты `claim_date` скользящее количество бы всегда равнялось 1 или же, при иной интерпретации данных, датасет получился бы размеров больше чем <Nx3>, где N - количество строк сгруппированные по определенному столбцу, что нарушало бы условия задачи. 

2. **disb_bank_loan_wo_tbc**. 
- **Решение**: Эта фича предполагает сумму экспозиций за исключением перечисленных банков и некоторых дополнительных условий от данных внутри contracts. 
- **Сопутствующие проблема**: Проблема была такая же, поиск ключа группировки для того чтобы сохранить условия конечного датасета. *Также следует добавить что в фиче `disb_bank_loan_wo_tbc` подсчитываются суммы экспозиций, которые правильнее хранить в формате float. По этому некоторые условия заполнения отсутствующих значений в виде `-1` или `-3` имеют тип float и в итоговом виде выглядят как `-3.0` и т.д. Данное решение было принято исключительно с целью оптимизации процесса, при увеличении обьема данных, конвертация типов данных из одного в другой и обратно негавивно сказалось бы на скорости обработки.*

2. **day_sinlastloan**. 
- **Решение**: Эта фича предполагает подсчет количества дней с последней выдачи кредита до даты `application_date`. В целом по подсчету этой фичи проблем не было. В условиях было прописано что нужно считать от максимальной, то есть последней даты выдачи кредита до даты `application_date`.

- **Сопутствующие проблема**: Отсутствуют.

**PS:** 
- **Следует добавить что, при выполнении дополнительных условий, то есть изменение процесса получения фич, нарушались бы условия основные - то есть получения датасета Nx3, где 3 - количество фич, а N - количество строк после группировки и агрегации.**
- **Подсчет новых фичей не произведен по причине сложности понимания природы данных и их происхождения из-за отсутствия документации**
---