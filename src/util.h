
bool check(const char *expected_mode, bool expected_heater_state)
{
    // check mode
    auto m = &id(mode);
    if (m->state != expected_mode)
    {
        return false;
    }

    // check heater state
    auto heater = &id(heater_1);
    if (heater->state != expected_heater_state)
    {
        return false;
    }

    // check error
    auto error = &id(error_code);
    if (error->has_state() && error->state != 0)
    {
        heater->turn_off();
        return false;
    }

    return true;
}