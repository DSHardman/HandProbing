void setup()
{
    Serial.begin(115200);

    while(!Serial);

    pinMode(HSPI_MOSI_PIN, OUTPUT);
    pinMode(HSPI_SCK_PIN, OUTPUT);
    pinMode(VSPI_MOSI_PIN, OUTPUT);
    pinMode(VSPI_SCK_PIN, OUTPUT);

    pinMode(CHIP_SEL_DRIVE, OUTPUT);
    pinMode(CHIP_SEL_MEAS, OUTPUT);
    pinMode(CHIP_SEL_MUX_SRC, OUTPUT);
    pinMode(CHIP_SEL_MUX_SINK, OUTPUT);
    pinMode(CHIP_SEL_MUX_VP, OUTPUT);
    pinMode(CHIP_SEL_MUX_VN, OUTPUT);
    pinMode(CHIP_SEL_AD5930, OUTPUT);

    pinMode(AD5930_INT_PIN, OUTPUT);
    pinMode(AD5930_CTRL_PIN, OUTPUT);
    pinMode(AD5930_STANDBY_PIN, OUTPUT);
    pinMode(AD5930_MSBOUT_PIN, INPUT);

    // ADC input
    pinMode(14, INPUT);
    pinMode(15, INPUT);
    pinMode(16, INPUT);
    pinMode(17, INPUT);
    pinMode(18, INPUT);
    pinMode(19, INPUT);
    pinMode(20, INPUT);
    pinMode(21, INPUT);
    pinMode(22, INPUT);
    pinMode(23, INPUT);

    digitalWrite(CHIP_SEL_DRIVE, HIGH);
    digitalWrite(CHIP_SEL_MEAS, HIGH);
    digitalWrite(CHIP_SEL_MUX_SRC, HIGH);
    digitalWrite(CHIP_SEL_MUX_SINK, HIGH);
    digitalWrite(CHIP_SEL_MUX_VP, HIGH);
    digitalWrite(CHIP_SEL_MUX_VN, HIGH);
    digitalWrite(CHIP_SEL_AD5930, HIGH);
    digitalWrite(AD5930_INT_PIN, LOW);
    digitalWrite(AD5930_CTRL_PIN, LOW);
    digitalWrite(AD5930_STANDBY_PIN, LOW);

    digitalWrite(ADS_PWR, LOW); //double-check
    digitalWrite(ADS_OE, LOW);

    AD5930_Write(CTRL_REG, 0b011111110011);
    AD5930_Set_Start_Freq(TEST_FREQ);

    AD5270_Lock(CHIP_SEL_DRIVE, 0);
    AD5270_Lock(CHIP_SEL_MEAS, 0);

    /* Start the frequency sweep */
    digitalWrite(AD5930_CTRL_PIN, HIGH);
    delay(100);

    calibrate_samples();

    AD5270_Set(CHIP_SEL_MEAS, 100); // MANUALLY SET GAINS
    AD5270_Set(CHIP_SEL_DRIVE, 900);

    mux_write(CHIP_SEL_MUX_SRC, elec_to_mux[0], MUX_EN);
    mux_write(CHIP_SEL_MUX_SINK, elec_to_mux[1], MUX_EN);
    mux_write(CHIP_SEL_MUX_VP, elec_to_mux[0], MUX_EN);
    mux_write(CHIP_SEL_MUX_VN, elec_to_mux[1], MUX_EN);


}

void loop()
{
    uint16_t i;

    read_frame(AD, AD, signal_rms, signal_mag, signal_phase, NUM_ELECTRODES);
    if (millis() - frame_delay > 350) {
        for(i = 0; i < NUM_MEAS; i++)
        {
            Serial.print(signal_rms[i], 4);
            Serial.print(", ");
            Serial.print(signal_mag[i], 4);
            Serial.print(", ");
            Serial.print(signal_phase[i], 4);
            Serial.print(", ");
            
        }
        Serial.print("\n");
        frame_delay = millis();
        delay(10);
    }
}
