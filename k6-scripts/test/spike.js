/**
 * A spike test is designed to determine how your system will perform under a sudden surge of traffic.
 * This test simulates a rapid increase in user load (spike) followed by a rapid decrease.
 *
 * Current configuration:
 * - Ramps up from 0 to 2000 virtual users over 2 minutes
 * - Ramps down to 0 users over 1 minute
 *
 * Use this test to:
 * - Verify system behavior under sudden extreme load
 * - Check if your system can handle rapid user number changes
 * - Identify potential breaking points during traffic spikes
 */
import http from 'k6/http';
import {sleep} from 'k6';

export const options = {
    stages: [
        {duration: '2m', target: 2000}, // spike up to 2000 users over 2 minutes
        {duration: '1m', target: 0}, // ramp-down to 0 users
    ]
};

export default function () {
    const res = http.get('https://test.k6.io');
    sleep(1);
}
