/**
 * Stress testing is a type of performance testing designed to evaluate how a system performs
 * under extreme conditions. It aims to:
 * - Determine the upper limits of system capacity
 * - Check how the system behaves under heavy load
 * - Identify breaking points and system bottlenecks
 * - Verify system stability and error handling
 *
 * This specific stress test configuration:
 * - Ramps up to 200 concurrent users over 10 minutes
 * - Maintains 200 users for 30 minutes of sustained load
 * - Gradually reduces to 0 users over 5 minutes for graceful shutdown
 * - Includes 1-second pause between iterations to simulate real user behavior
 *
 * The test helps verify system stability and performance under heavy load conditions.
 */
import http from 'k6/http';
import {sleep} from 'k6';

export const options = {
    stages: [
        {duration: '10m', target: 200}, // simulate ramp-up of traffic from 1 to 100 users over 5 minutes.
        {duration: '30m', target: 200}, // stay at 100 users for 30 minutes/
        {duration: '5m', target: 0}, // ramp-down to 0 users/
    ]
};

export default function () {
    const res = http.get('https://test.k6.io');
    sleep(1);
}
