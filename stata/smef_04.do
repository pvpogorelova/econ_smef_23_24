clear
set more off
cd /Users/polinapogorelova/Desktop/СМЭФ_Эконометрика/Эконометрика_23_24
log using sem4.log

use CARD.DTA
describe // описание набора данных
summarize // описательные статистики переменных

* 1. Метод наименьших квадратов
reg lwage educ exper expersq black south smsa smsa66 reg662 reg663 reg664 reg665 reg666 reg667 reg668 reg669
est store ols
estat ovtest // RESET-test  (тест Рамсея). Ho: нет пропущенных переменных
predict yhat, xb // сохраняем прогноз по модели
tabstat yhat, statistics(mean) by(south) // среднее значение прогноза по двум категориям бинарной переменной south (tabstat отображает сводную статистику для ряда числовых переменных в одной таблице)
adjust exper = 10, by(south) // команда adjust отображает среднее модельное значение зависимой переменной для опыта = 10 лет в каждой категории переменной south

* 2. Метод инструментальных переменных и 2-МНК
* Проанализируем, какие из имеющихся переменных могут быть инструментами для educ

* nearc4 - инструмент для educ
ivregress 2sls lwage (educ = nearc4) exper expersq black south smsa smsa66 reg662 reg663 reg664 reg665 reg666 reg667 reg668 reg669, first
est store iv

estat firststage // тестирование релевантности (качества) инструментов. H0: инструменты слабые
hausman iv ols // тест Хаусмана на проверку эндогенности регрессоров. H0: OLS-оценки. H1: IV-оценки

* nearc4 и nearc2 - инструменты для educ
ivregress 2sls lwage (educ = nearc4 nearc2) exper expersq black south smsa smsa66 reg662 reg663 reg664 reg665 reg666 reg667 reg668 reg669, first
est store iv2
estat firststage // тестирование релевантности (качества) инструментов. H0: инструменты слабые
estat overid // тестирование валидности (экзогенности) инструментов (l>=k) (тест Саргана). H0: все инструменты экзогенные (не коррелируют с ошибкой). H1: хотя бы один из инструментов эндогенный
hausman iv2 ols // тест Хаусмана на проверку эндогенности регрессоров. H0: OLS-оценки. H1: IV-оценки

* fatheduc, motheduc - инструменты для educ
ivregress 2sls lwage (educ = fatheduc motheduc) educ exper expersq black south smsa smsa66 reg662 reg663 reg664 reg665 reg666 reg667 reg668 reg669, first
est store iv3
* Тестирование инструментов
estat firststage // тестирование релевантности (качества) инструментов. H0: инструменты слабые
estat overid // тестирование валидности (экзогенности) инструментов (l>=k) (тест Саргана). H0: все инструменты экзогенные (не коррелируют с ошибкой). H1: хотя бы один из инструментов эндогенный
hausman iv3 ols // тест Хаусмана на проверку эндогенности регрессоров. H0: OLS-оценки. H1: IV-оценки

* nearc4, fatheduc, motheduc - инструменты для educ
ivregress 2sls lwage (educ = nearc4 fatheduc motheduc) educ exper expersq black south smsa smsa66 reg662 reg663 reg664 reg665 reg666 reg667 reg668 reg669, first
estat iv4
estat firststage
estat overid
hausman iv4 ols // тест Хаусмана на проверку эндогенности регрессоров. H0: OLS-оценки. H1: IV-оценки
close
