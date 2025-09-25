/**
 * Soak testing is a type of performance testing that evaluates system's stability
 * and performance over an extended period of continuous operation. The main goals are:
 *
 * 1. Verify system stability over long duration
 * 2. Detect memory leaks and resource depletion
 * 3. Monitor system behavior under sustained normal load
 * 4. Identify performance degradation over time
 *
 * This test configuration:
 * - Ramps up to 100 users over 5 minutes
 * - Maintains 100 concurrent users for 8 hours
 * - Ramps down to 0 users over 5 minutes
 *
 * The extended duration helps identify issues that might not appear in shorter tests,
 * such as memory leaks, resource exhaustion, or performance degradation over time.
 */
import http from 'k6/http';
import {sleep} from 'k6';

export const options = {
    stages: [
        {duration: '5m', target: 100}, // spike up to 2000 users over 2 minutes
        {duration: '8h', target: 100}, // ramp-down to 0 users
        {duration: '5m', target: 0}, // ramp-down to 0 users
    ]
};

export default function () {
    const res = http.get('https://test.k6.io');
    sleep(1);
}
