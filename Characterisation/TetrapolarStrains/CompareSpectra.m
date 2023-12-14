frequencies = [200 500 800 1000 2000 5000 8000 10000 15000 20000 30000 40000 50000 60000 70000];

subplot(3,1,1);

[spectra, ~] = ExtractSpectra("base1.log");
touches = find(spectra(:, 1)) < 1e5;
base1 = mean(spectra(touches, :));
plot(frequencies, base1);

hold on

[spectra, ~] = ExtractSpectra("one1.log");
touches = find(spectra(:, 1)) < 1e5;
one1 = mean(spectra(touches, :));
plot(frequencies, one1);

[spectra, ~] = ExtractSpectra("two1.log");
touches = find(spectra(:, 1)) < 1e5;
two1 = mean(spectra(touches, :));
plot(frequencies, two1);

set(gca, 'YScale', 'log', 'XScale', 'log');

subplot(3,1,2);

[spectra, ~] = ExtractSpectra("base2.log");
touches = find(spectra(:, 1)) < 1e5;
base2 = mean(spectra(touches, :));
plot(frequencies, base2);

hold on

[spectra, ~] = ExtractSpectra("one2.log");
touches = find(spectra(:, 1)) < 1e5;
one2 = mean(spectra(touches, :));
plot(frequencies, one2);

spectra = ExtractSpectranotimestamp("two2.log");
touches = find(spectra(:, 1)) < 1e5;
two2 = mean(spectra(touches, :));
plot(frequencies, two2);

set(gca, 'YScale', 'log', 'XScale', 'log');

subplot(3,1,3);
plot(frequencies, (base1+base2)/2);
hold on
plot(frequencies, (one1+one2)/2);
plot(frequencies, (two1+two2)/2);

set(gca, 'YScale', 'log'); % , 'XScale', 'log');