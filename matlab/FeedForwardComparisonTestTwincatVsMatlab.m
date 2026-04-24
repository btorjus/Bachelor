% === Test bench for valveFeedForward ===
clear; clc; close all;

d = 65;
dr = 35;
A = pi*d^2/4;
Ar = pi*dr^2/4;
Aa = A - Ar;
A_mm2 = A;
Aa_mm2 = Aa;

u_dead_up    = 0.236;
u_dead_down  = 0.206;
spool_dead_up   = 1.1182 * u_dead_up   - 0.0325;
spool_dead_down = 1.1075 * u_dead_down - 0.0416;
slope_Kv_up   = 0.270407;
slope_Kv_down = 0.230397;

pA_tests    = [69.86297, 78.79879, 74.06232] * 1e5;
pB_tests    = [0, 0, 0] * 1e5;
pP_tests    = [100.7678, 99.99513, 100.3636] * 1e5;
xdot_tests  = [0.0145620821947093, 0.038124, 0.044817];

% Constants
Kv_conv = sqrt(1e-5) / 6e4;
dP_min  = 1e5;
A_m2  = A_mm2  * 1e-6;
Aa_m2 = Aa_mm2 * 1e-6;

fprintf('%-10s  %-12s  %-12s  %-12s  %-12s  %-12s  %-12s\n', ...
    'Scenario', 'x_dot_ref', 'Kv_ref', 'u_spool', 'u_FF', 'Q_req', 'dP [bar]');
fprintf('%s\n', repmat('-', 1, 86));

for i = 1:3
    pA = pA_tests(i);
    pB = pB_tests(i);
    pP = pP_tests(i);
    x_dot_ref = xdot_tests(i);

    if x_dot_ref > 0
        Q_req = A_m2 * x_dot_ref;
        dP    = max(pP - pA, dP_min);
        dir   = 1;
        Kv_ref = (Q_req / sqrt(dP)) / Kv_conv;
        if Kv_ref < 0.1
            u_spool = spool_dead_up + slope_Kv_up * Kv_ref;
        else
            u_spool = 0.0018653*Kv_ref^6 - 0.033672*Kv_ref^5 + 0.22033*Kv_ref^4 ...
                    - 0.65618*Kv_ref^3 + 0.83411*Kv_ref^2 - 0.047269*Kv_ref + 0.26252;
        end
        u_mag = (u_spool + 0.0325) / 1.1182;

    elseif x_dot_ref < 0
        Q_req = Aa_m2 * abs(x_dot_ref);
        dP    = max(pP - pB, dP_min);
        dir   = -1;
        Kv_ref = (Q_req / sqrt(dP)) / Kv_conv;
        if Kv_ref < 0.1
            u_spool = spool_dead_down + slope_Kv_down * Kv_ref;
        else
            u_spool = 0.00098272*Kv_ref^6 - 0.017507*Kv_ref^5 + 0.11599*Kv_ref^4 ...
                    - 0.34851*Kv_ref^3 + 0.41222*Kv_ref^2 + 0.17643*Kv_ref + 0.2076;
        end
        u_mag = (u_spool + 0.0416) / 1.1075;

    else
        u_spool = 0;
        u_FF    = 0;
        dP      = 0;
        Q_req   = 0;
        fprintf('%-10d  %-12.4f  %-12.6f  %-12.6f  %-12.6f  %-12.6e  %-12.2f\n', ...
        i, x_dot_ref, Kv_ref, u_spool, u_FF, Q_req, dP/1e5);
        continue;
    end

    u_FF = dir * max(min(u_mag, 1), -1);

    fprintf('%-10d  %-12.4f  %-12.6f  %-12.6f  %-12.6f  %-12.6e  %-12.2f\n', ...
        i, x_dot_ref, Kv_ref, u_spool, u_FF, Q_req, dP/1e5);
end