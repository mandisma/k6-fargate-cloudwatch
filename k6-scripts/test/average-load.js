/**
 * Average Load Testing simulates a consistent, expected load on a system over an extended period.
 * It aims to verify system behavior under normal, sustained usage conditions that represent
 * typical production workload. This type of testing helps to:
 * - Validate system stability during regular operation
 * - Identify performance bottlenecks under normal load
 * - Ensure consistent response times during sustained usage
 * - Verify system resources utilization at average load levels
 */

import http from 'k6/http';
import {sleep} from 'k6';

export const options = {
    stages: [
        {duration: '5m', target: 100}, // Ramp-up phase: Gradually increase virtual users from 0 to 100 over 5 minutes to avoid shock loading
        {duration: '30m', target: 100}, // Sustained load phase: Maintain 100 concurrent users for 30 minutes to simulate steady-state operation
        {duration: '5m', target: 0}, // Ramp-down phase: Gradually decrease to 0 users over 5 minutes for graceful test completion
    ]
};

export default function () {
    const res = http.get('https://test.k6.io');
    sleep(1);
}
